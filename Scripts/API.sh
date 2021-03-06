#!/bin/bash

API=https://api.github.com/repos/$1/releases/latest

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
		[[ ! ${verify} || ${verify} == null ]] && verify="-"
		printf "%-45s %-10s %-5s %-20s %-20s %-10s %-15s %s\n" ${name} ${download_count} ${verify} ${version} ${updated_at} ${size} ${browser_download_url} >> API_File
	;;
	esac
done
