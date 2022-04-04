#!/bin/bash

function TITLE() {
	clear && echo "AutoUpdate Script by Hyy2001 ${SCRIPT_VER}"
}

function ECHO() {
	White="\e[0m"
	Yellow="\e[33m"
	Red="\e[31m"
	Blue="\e[34m"
	Grey="\e[36m"
	Green="\e[32m"
	[[ ! $1 ]] && {
		echo -ne "\n${Grey}[$(date "+%H:%M:%S")]${White} "
	} || {
		while [[ $1 ]];do
			case "$1" in
			r | g | b | y | x)
				case "$1" in
				r) Color="${Red}";;
				g) Color="${Green}";;
				b) Color="${Blue}";;
				y) Color="${Yellow}";;
				x) Color="${Grey}";;
				esac
				shift
			;;
			*)
				Message="$1"
				break
			;;
			esac
		done
		echo -e "\n${Grey}[$(date "+%H:%M:%S")]${White}${Color} ${Message}${White}"
	}
}

function CHECK_PKG() {
	if [[ $(command -v $1 2> /dev/null) ]]
	then
		return 0
	else
		return 1
	fi
}

function KILL_PROCESS() {
	local i;for i in $(ps -efww | grep -v grep | grep $1 | grep -v $$ | awk '{print $2}');do
		kill -9 ${i} 2> /dev/null &
	done
}

function AutoUpdate_Main() {
	[[ ! -d ${WORK} ]] && mkdir -p ${WORK}
	cd ${WORK}

	TITLE

	[[ -f API_Cache ]] && rm -f API_Cache
	ECHO "正在检查版本更新, 请稍后 ..."
	wget -q ${API} -O - > API_Cache
	if [[ $? != 0 || ! -e API_Cache ]]
	then
		ECHO "检查更新失败,请检查网络后再试!"
		exit 1
	fi
	rm -f API_File && touch -f API_File

	for i in $(seq 0 $(jq ".assets | length" API_Cache 2> /dev/null));do
		eval name=$(jq ".assets[${i}].name" API_Cache 2> /dev/null)
		[[ ${name} == null ]] && continue
		case ${name} in
		OTA*)
			eval version=$(echo ${name} | egrep -o "\-[0-9]+\-" | sed -r 's/-(.*)-/\1/')
			eval verify=$(echo ${name} | egrep -o "\-[a-z0-9]+" | cut -c2-6 | awk 'END{print}')
			eval browser_download_url=$(jq ".assets[${i}].browser_download_url" API_Cache 2> /dev/null)
			eval size=$(jq ".assets[${i}].size" API_Cache 2> /dev/null | awk '{a=$1/1048576} {printf("%.2f\n",a)}')
			eval updated_at=$(jq ".assets[${i}].updated_at" API_Cache 2> /dev/null | sed 's/[-:TZ]//g')
			eval download_count=$(jq ".assets[${i}].download_count" API_Cache 2> /dev/null)
			[[ ! ${version} || ${version} == null ]] && version="-"
			[[ ! ${verify} || ${verify} == null ]] && verify="-"
			printf "%-45s %-10s %-5s %-20s %-20s %-10s %-15s %s\n" ${name} ${download_count} ${verify} ${version} ${updated_at} ${size} ${browser_download_url} >> API_File
		;;
		esac
	done
}

if [[ $(CHECK_PKG jq ; echo $?) != 0 ]]
then
	ECHO r "请安装软件包 jq"
	exit 1
fi

KILL_PROCESS AutoUpdate.sh

SCRIPT_VER=V1.0

GIT_REPO=Hyy2001X/hi_AutoUpdate
GIT_TAG=OTA
GIT_RELEASE=https://github.com/${Hyy2001X/hi_AutoUpdate}/releases/download/${GIT_TAG}
API=https://api.github.com/repos/${GIT_REPO}/releases/latest

TARGET=$(dmesg | grep "CPU: hi" | awk -F ':[ ]' '/CPU/{printf ($2)}')
SPACE=$(df -m /tmp | grep -v File | awk '{print $4}')
CURRENT_VER=$(cat /etc/nasversion 2> /dev/null)
WORK=/tmp/AutoUpdate

AutoUpdate_Main $*