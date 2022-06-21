#!/bin/bash

filedump="" # filedump="dump.raw"
filelog="log"
pathto="vol3"
volcmd="vol3"
skipped="windows.memmap.Memmap windows.dumpfiles.DumpFiles"

__usage() {
	echo "usage:
vol3-analyse.sh <DUMP> [PROFILE] [PATHTO]"
	exit
}

__init() {
	# pathto
	[ -d "${pathto}" ] || mkdir -p "${pathto}"

	echo -e "\n======================================================  $(date "+%Y%m%d-%H%M%S")" >> ${pathto}/${filelog}

	# symbols & windows.info
	#plug=windows.info.Info
	#file=${pathto}/${plug}
	#if ! [ -f ${file} ]; then
	#	echo -e "\n$(date "+%Y%m%d-%H%M%S") ----------- ${plug}" >> ${pathto}/${filelog}
	#	echo " ${file}"
	#	echo " ${file}"
	#	${volcmd} -f ${filedump} -r quick $plug 1>${file} 2>>${pathto}/${filelog}
	#	sudo chown ${USER}:${USER} ${file} ${pathto}/${filelog}
	#fi
}

__vol() {
	for plug in $1; do
		if [[ " ${skipped} " = *" ${plug} "* ]]; then
			echo -e "\n$(date "+%Y%m%d-%H%M%S") ----------- ${plug} skipped" >> ${pathto}/${filelog}
		else
			echo -e "\n$(date "+%Y%m%d-%H%M%S") ----------- ${plug}" >> ${pathto}/${filelog}
			for render in $2; do
				[ "${render}" = quick ] && file=${pathto}/${plug} || file=${pathto}/${plug}.${render}
				if ! [ -f "${file}" ]; then
					echo " ${file}"
					sudo ${volcmd} -f ${filedump} -r ${render} $plug 1>${file} 2>>${pathto}/${filelog}
					sudo chown ${USER}:${USER} ${file}
				fi
			done
		fi
	done
}

# help
[[ "$*" = *"-h" || ! "$*" ]] && __usage

# file
[ "$1" ] && filedump="$1"
! [ "${filedump}" ] && echo "No file given" && __usage
# pathto
[ "$2" ] && pathto="$2"
! [ "${pathto}" ] && pathto="vol3"

__init 

plugs_win=$(volatility -h|sed -n 's|^ *\(windows\.[^ ]\+\).*$|\1|p')
plugs_spe="banners.Banners configwriter.ConfigWriter frameworkinfo.FrameworkInfo isfinfo.IsfInfo layerwriter.LayerWriter timeliner.Timeliner yarascan.YaraScan"
plugs="${plugs_win} ${plugs_spe}"

#for plug in ${plugs_win} ${plugs_spe}; do
for plug in ${plugs}; do
	__vol ${plug} "quick csv"
done

sudo chown ${USER}:${USER} -R ${pathto}
