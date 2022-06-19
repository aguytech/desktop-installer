#!/bin/bash

filedump="" # filedump="dump.raw"
filelog="log"
profile="" # profile="Win7SP0x86"
pathto="vol2"
volcmd="vol2"

__usage() {
	echo "usage:
vol2-analyse.sh <DUMP> [PROFILE] [PATHTO]"
	exit
}
__profile() {
	[ -f kdbgscan ] || vol2 -f ${filedump} --output text kdbgscan > kdbgscan 2>/dev/null
	grep -i ^profile kdbgscan | sed "s/^Profile.*: //"
	read -p "Give a profile: " profile
	! [ "${profile}" ] && echo "No profile given" && exit 1
}
__vol() {
	for plug in $1; do
		echo " $(date "+%Y%m%d-%H%M%S") - ${plug}" >> ${pathto}/${filelog}
		file=${pathto}/${plug}
		[ ! -f "${file}" ] && echo " ${file}" && ${volcmd} -f ${filedump} --profile ${profile} --output text $plug 1>${file} 2>>${pathto}/${filelog}
		file=${pathto}/${plug}.grep
		[ "$2" = grep ] && [ ! -f "${file}" ] && echo " ${file}" && ${volcmd} -f ${filedump} --profile ${profile} --output greptext $plug 1>${file} 2>>${pathto}/${filelog}
	done
}

[[ "$*" = *"-h" || ! "$*" ]] && __usage

# file
[ "$1" ] && filedump="$1"
! [ "${filedump}" ] && echo "No file given" && __usage
# profile
[ "$2" ] && profile="$2"
! [ "${profile}" ] && __profile
# pathto
[ "$3" ] && pathto="$3"
! [ "${pathto}" ] && pathto="vol2"

[ -d "${pathto}" ] || mkdir -p "${pathto}"

echo -e "\n------------------------------------------------------  $(date "+%Y%m%d-%H%M%S")" >> ${pathto}/${filelog}

__vol "imageinfo" grep

echo -e "\n- DEVICE" && __vol "devicetree mbrparser" grep
echo -e "\n- PROCESS" && __vol "envars getsids handles privs pslist psscan pstree psxview sessions thrdscan threads" grep
echo -e "\n- COMMAND" && __vol "cmdline cmdscan consoles" grep
echo -e "\n- EXE" && __vol "joblinks malfind privs shimcache verinfo" grep
echo -e "\n- DLL" && __vol "dlllist ldrmodules" grep
echo -e "\n- DUMP" && __vol "cachedump hashdump hivedump lsadump" grep
echo -e "\n- FILE" && __vol "filescan mftparser notepad" grep
echo -e "\n- HIVE" && __vol "amcache hivescan hivedump hivelist shimcache userassist" grep
# echo -e "\n- HOOK" && __vol "apihooks eventhooks messagehooks" grep
echo -e "\n- MODULE" && __vol "drivermodule modscan modules timers unloadedmodules" grep
echo -e "\n- MEMORY" && __vol "bigpools cachedump hpakextract hpakinfo patcher" grep
echo -e "\n- NETWORK" && __vol "connections connscan netscan sockets sockscan" grep
echo -e "\n- PASSWD" && __vol "hashdump lsadump truecryptmaster truecryptpassphrase truecryptsummary" grep
echo -e "\n- SERVICE" && __vol "getservicesids servicediff svcscan" grep
echo -e "\n- SYSTEM" && __vol "auditpol bioskbd callbacks crashinfo driverirp driverscan envars evtlogs kpcrscan machoinfo mutantscan objtypescan shutdowntime symlinkscan" grep
echo -e "\n- USER" && __vol "atoms atomscan clipboard deskscan gahti sessions userassist userhandles" grep
echo -e "\n- TIMELINE" && __vol "timeliner timers" grep
echo -e "\n- VAD" && __vol "vaddump vadinfo vadtree vadwalk" grep
echo -e "\n- VIRTUAL" && __vol "qemuinfo vboxinfo vmwareinfo" grep
echo -e "\n- WINDOWS" && __vol "windows wintree wndscan" grep
echo -e "\n- OTHERS" && __vol "editbox gditimers gdt idt iehistory shellbags"

# specials
specials="dlldump dumpfiles hibinfo hivedump imagecopy impscan memdump memmap moddump poolpeek printkey procdump raw2dm screenshot strings"
missing="dumpcerts yara"

sed -i "/^Volatility Foundation Volatility Framework/d" ${pathto}/${filelog}
