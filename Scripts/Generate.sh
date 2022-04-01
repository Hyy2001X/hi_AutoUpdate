#!/bin/bash

REPO=https://github.com/$1
API=https://api.github.com/repos/$1/releases/latest
WORK=${GITHUB_WORKSPACE}
OTA_VERSION=$(date +%Y%m%d%H%M%S)

wget -q ${API} -O - > API_Cache
touch -f API_File

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
		[[ ! ${browser_download_url} || ${browser_download_url} == null ]] && continue
		[[ ! ${size} || ${size} == null || ${size} == 0 ]] && size="-" || size="${size}MB"
		[[ ! ${updated_at} || ${updated_at} == null ]] && updated_at="-"
		[[ ! ${download_count} || ${download_count} == null ]] && download_count="-"
		[[ ! ${verify} || ${verify} == null ]] && verify="-"
		printf "%-45s %-10s %-5s %-20s %-20s %-10s %-15s %s\n" ${name} ${download_count} ${verify} ${version} ${updated_at} ${size} ${browser_download_url} >> API_File
	;;
	esac
done

cat API_File

mkdir -p OTA

for TARGET_PATH in $(ls -1 | grep 'OTA_')
do
	TARGET=${TARGET_PATH/OTA_/}
	gzip -r -9 -c ${TARGET_PATH} > OTA/${TARGET}.gz

	MD5=$(md5sum OTA/${TARGET}.gz | awk '{print $1}' | cut -c1-5)
	OTA_PKG=OTA-${TARGET}-${OTA_VERSION}-${MD5}.gz

	if [[ ! $(cat API_File 2> /dev/null | awk '{print $3}') =~ ${MD5} ]]
	then
		echo "Generating OTA for ${TARGET} ..."
		mv -f OTA/${TARGET}.gz OTA/${OTA_PKG}
		echo "OTA Package: ${OTA_PKG}"
	else
		echo "Nothing to be generated"
		rm -f OTA/${TARGET}.gz
	fi
done
