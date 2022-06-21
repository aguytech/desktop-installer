#!/bin/bash

__usage() {
	echo "
${script} [options] <mount/umount> <file>
Mounts disk file"
	exit
}
__mod_nbd() {
	# no module nbd
	! modinfo nbd >/dev/null 2>&1 && echo "Unable to find module nbd" && exit 1
	lsmod 2>/dev/null | grep -q ^nbd || modprobe nbd
}

__mount_nbd() {
	# already mounted
	grep -q "${file}$" ${nbd_file} && echo "${file} already mounted in $(grep "${file}$" ${nbd_file} | cut -f1)" && return

	for block in $(ls -d /sys/class/block/nbd[0-9] | sort) ; do 
		if [ $(cat ${block}/size) = 0 ]; then
			if qemu-nbd -c /dev/${block##*/} "${file}" -f qcow2; then
				echo -e "/dev/${block##*/}\t${file}" >> ${nbd_file}
			else
				echo "Unable to mount ${file} in /dev/${block##*/}"
				exit 1
			fi
			break
		fi
	done
}

__umount_nbd() {
	nbd=$(grep "$1$" ${nbd_file} | cut -f1)

	if [ "${nbd}" ] && [ $(cat /sys/class/block/${nbd#/dev/}/size) -gt 0 ]; then
		if qemu-nbd -d ${nbd}; then
			sed -i "\|$1$|d" ${nbd_file}
		fi
	fi
}

__mount_dev() {
	nbd_base=$(grep "$1$" ${nbd_file} | cut -f1)
	[ -z "${nbd_base}" ] && return

	for nbd in $(ls -d1 ${nbd_base}* | grep -v "^${nbd_base}$" ); do
		path="${path_base_nbd}/${nbd#/dev/}"
		[ -d "${path}" ] || mkdir -p ${path}
		grep -q ${nbd} /proc/mounts && echo "${nbd} already mounted" && continue
		mount ${nbd} ${path} && echo "${nbd} mounted"
	done
}

__umount_dev() {
	nbd_base=$(grep "$1$" ${nbd_file} | cut -f1)
	[ -z "${nbd_base}" ] && return

	for nbd in $(ls -d1 ${nbd_base}* | grep -v "^${nbd_base}$" ); do
		path="${path_base_nbd}/${nbd#/dev/}"
		if grep -q ${nbd} /proc/mounts && umount ${path}; then
			echo "${nbd} unmounted"
			rmdir ${path}
		fi
	done
}

__file() {
	[ -z "$1" ] && echo -e "No file given" && __usage
	! [ -f "$1" ] && echo "'$1' is not a file" && __usage
	file="$1"
}

__init() {
	# variables
	script=${0##*/}
	nbd_file=/tmp/${script}
	path_base_nbd=/vms/nbd

	# nbd_file
	[ -f ${nbd_file} ] || touch ${nbd_file}
	# root privileges
	[ "${USER}" != root  ] && echo "Root privileges are needed" && __usage
	# Wrong parameters numbers
	[ "$#" -lt 2 ] && echo "Wrong parameters numbers: $#" && __usage
}

__init $*

case $1 in
	mount)
		__file "$2"
		__mod_nbd
		__mount_nbd "$2"
		__mount_dev "$2"
	;;
	umount)
		__file "$2"
		__mod_nbd
		__umount_dev "$2"
		__umount_nbd "$2"
	;;
	*)
		echo "No good command given to ${script}"
		__usage
	;;
esac
