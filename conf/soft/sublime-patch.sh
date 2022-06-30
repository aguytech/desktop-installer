#!/bin/bash

############################   DATA

####   TEXT

declare -a _VERSIONS_TEXT _METHODS_TEXT _COMMENTS_TEXT
i=0

# method 1
# Disable Text's License Checks
i=$((i+1))
_VERSIONS_TEXT[i]="4113"
#0x000220  E087
_OFFSETS_TEXT[i]="0x04D648  000000
0x36567C  4831C0C390909090909090909090909090
0x367171  4831C048FFC0C39090909090"
_COMMENTS_TEXT[i]="You have to enter this fake license: \e[0;0m
-- BEGIN LICENSE --
Generic Name
Unlimited User License
EA7E-81044230
0C0CD4A8 CAA317D9 CCABD1AC 434C984C
7E4A0B13 77893C3E DD0A5BA1 B2EB721C
4BAAB4C4 9B96437D 14EB743E 7DB55D9C
7CA26EE2 67C3B4EC 29B2C65A 88D90C59
CB6CCBA5 7DE6177B C02C2826 8C9A21B0
6AB1A5B6 20B09EA2 01C979BD 29670B19
92DC6D90 6E365849 4AB84739 5B4C3EA1
048CC1D0 9748ED54 CAC9D585 90CAD815
-- END LICENSE --
"

# method 1
i=$((i+1))
_VERSIONS_TEXT[i]="4126"
_OFFSETS_TEXT[i]="0x00385797  0f85
0x0038583d  751f"
_COMMENTS_TEXT[i]="You have to enter the good license 3211 : \e[0;0m
----- BEGIN LICENSE -----
Member J2TeaM
Single User License
EA7E-1011316
D7DA350E 1B8B0760 972F8B60 F3E64036
B9B4E234 F356F38F 0AD1E3B7 0E9C5FAD
FA0A2ABE 25F65BD8 D51458E5 3923CE80
87428428 79079A01 AA69F319 A1AF29A4
A684C2DC 0B1583D4 19CBD290 217618CD
5653E0A0 BACE3948 BB2EE45E 422D2C87
DD9AF44B 99C49590 D2DBDEE1 75860FD2
8C8BB2AD B2ECE5A4 EFC08AF2 25A9B864
------ END LICENSE ------
"

# method 2
# Disable Text's License Checks
i=$((i+1))
_VERSIONS_TEXT[i]="4126"
_OFFSETS_TEXT[i]="0x00385492  4831C0C3
0x0037B675  9090909090
0x0037B68B  9090909090
0x00386F4F  4831C048FFC0C3
0x00385156  C3
0x0036EF50  C3"
_COMMENTS_TEXT[i]="You have to enter this fake license: \e[0;0m
-- BEGIN LICENSE --
Generic Name
Unlimited User License
EA7E-81044230
0C0CD4A8 CAA317D9 CCABD1AC 434C984C
7E4A0B13 77893C3E DD0A5BA1 B2EB721C
4BAAB4C4 9B96437D 14EB743E 7DB55D9C
7CA26EE2 67C3B4EC 29B2C65A 88D90C59
CB6CCBA5 7DE6177B C02C2826 8C9A21B0
6AB1A5B6 20B09EA2 01C979BD 29670B19
92DC6D90 6E365849 4AB84739 5B4C3EA1
048CC1D0 9748ED54 CAC9D585 90CAD815
-- END LICENSE --
"

####   MERGE

declare -a _VERSIONS_MERGE _OFFSETS_MERGE _COMMENTS_MERGE
i=0

# method 1
# Disable Text's License Checks
i=$((i+1))
_VERSIONS_MERGE[i]="2059"
#0x000220  F08A
#0x3A67FE  4831C048FFC0C39090909090
_OFFSETS_MERGE[i]="0x3A40D2  C3
0x3A514E  C3
0x3A5400  48C7C019010000C3
0x3A67FE  4831C048FFC0C3
0x3A7EC9  9090909090
0x3A7EE4  9090909090"
_COMMENTS_MERGE[i]="You have to enter this fake license: \e[0;0m
-- BEGIN LICENSE --
Generic Name
Unlimited User License
EA7E-81044230
0C0CD4A8 CAA317D9 CCABD1AC 434C984C
7E4A0B13 77893C3E DD0A5BA1 B2EB721C
4BAAB4C4 9B96437D 14EB743E 7DB55D9C
7CA26EE2 67C3B4EC 29B2C65A 88D90C59
CB6CCBA5 7DE6177B C02C2826 8C9A21B0
6AB1A5B6 20B09EA2 01C979BD 29670B19
92DC6D90 6E365849 4AB84739 5B4C3EA1
048CC1D0 9748ED54 CAC9D585 90CAD815
-- END LICENSE --
"

####   FIREWALL

firewall='
# sublime-text hack
127.0.0.1 sublimetext.com
127.0.0.1 sublimemerge.com
127.0.0.1 sublimehq.com
127.0.0.1 telemetry.sublimehq.com
127.0.0.1 license.sublimehq.com
127.0.0.1 45.55.255.55
127.0.0.1 45.55.41.223'

yellow='\e[0;93m'; yellowb='\e[1;93m'; cclear='\e[0;0m';

############################   FUNCTIONS

_echo() { echo -e "\n${yellow}> $*${cclear}"; }
_patch() {
	while read offset text; do
		echo ${offset} ${text}
		text=$( echo ${text} | sed 's/../\\x&/g' )
		printf "${text}" | dd of=${_FILE} bs=1 seek=$((${offset})) conv=notrunc
	done <<<"$*"
}

############################   DATA

# firewall
file="/etc/hosts"
if ! grep -q 'sublime-text hack' ${file}; then
	_echo "Patch /etc/fstab"
	sudo sh -c "echo '${firewall}' >> ${file}"
fi

# software
_echo "Select the software to patch: "
select _SOFTWARE in sublime_text sublime_merge; do [ "${_SOFTWARE}" ] && break || echo "Select a valid option"; done

case ${_SOFTWARE} in
	sublime_text) _VERSIONS=$( for i in ${!_VERSIONS_TEXT[*]}; do tmp="${_VERSIONS_TEXT[$i]}"; printf "$i:${tmp// /-} "; done )  ;;
	sublime_merge)  _VERSIONS=$( for i in ${!_VERSIONS_MERGE[*]}; do tmp="${_VERSIONS_MERGE[$i]}"; printf "$i:${tmp// /-} "; done )  ;;
esac

# file
_FILE=/opt/${_SOFTWARE}/${_SOFTWARE}
! [ -f ${_FILE} ] && _echo "Unable to found file: ${_FILE}"
while ! [ -f ${_FILE} ]; do
	read -p "Give the full path of ${_SOFTWARE}: " _FILE
done
! [ -w ${_FILE} ] && echo "${_FILE} is not writeable for ${USER}" && exit 1
_VERFILE=$( grep --only-matching --byte-offset --max-count=1 --text --perl-regexp "version=...." ${_FILE} | sed -n 's/^.*=\(.*\)$/\1/p' )

# method
_echo "Select a method for patching: id:sublime_versions"
select _METHOD in ${_VERSIONS}; do [ "${_METHOD}" ] && break || printf "Select a valid option\n"; done
_METHOD=${_METHOD%%:*}

case ${_SOFTWARE} in
	sublime_text)
		_OFFSETS="${_OFFSETS_TEXT[${_METHOD}]}"
		_COMMENTS="${_COMMENTS_TEXT[${_METHOD}]}"
		_VERTEST=" ${_VERSIONS_TEXT[${_METHOD}]} "
		;;
	sublime_merge)
		_OFFSETS="${_OFFSETS_MERGE[${_METHOD}]}"
		_COMMENTS="${_COMMENTS_MERGE[${_METHOD}]}"
		_VERTEST=" ${_VERSIONS_MERGE[${_METHOD}]} "
		;;
esac

echo _SOFTWARE=${_SOFTWARE}
echo _METHOD=${_METHOD}
echo _OFFSETS=${_OFFSETS}

# test version
if ! [[ "${_VERTEST}" = *" ${_VERFILE} "* ]]; then
	_echo "The version of file: ${_VERFILE} is not in versions of the selected method: ${_VERTEST}"
	read -p "Valid to continue: "
fi

# save original file
if ! [ -f ${_FILE}.origin ]; then
	cp -a ${_FILE} ${_FILE}.origin
	_echo "Save original ${_FILE} to ${_FILE}.origin"
fi

# patch
_echo "Patch ${_FILE} with method ${_METHOD}"
_patch "${_OFFSETS}" && _echo "Apply patch successfully" || exit 1

[ "${_COMMENTS}" ] && _echo "${_COMMENTS}"
