#!/bin/bash

action=s1 && shift

case ${action} in
	start)
		[ -z "$2" ] && echo "No device given to mount.sh" && exit 1
		if blkid | grep -q "LABEL=\"$2\"" && grep -q "^UUID=.* */$2 *" /etc/fstab; then
			mount $2
		fi
	;;

	stop)
		umount $2
	;;
	*)
		echo "No command given to mount.sh"
		exit 1
	;;
esac
