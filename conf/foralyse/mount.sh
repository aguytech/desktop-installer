#!/bin/bash

case $1 in
	start)
		[ -z "$2" ] && echo "No device given to mount.sh" && exit 1
		if blkid | grep -q "LABEL=\"$2\"" && grep -q "^UUID=.* */$2 *" /etc/fstab; then
			mount /cases
		fi
	;;

	stop)
		umount /cases
	;;
	*)
		echo "No command given to mount.sh"
		exit 1
	;;
esac
