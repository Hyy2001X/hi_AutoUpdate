#!/bin/bash

WORK="${GITHUB_WORKSPACE}"
OTA_VERSION=$(date +%Y%m%d%H%M%S)

mkdir -p OTA

for TARGET_PATH in $(ls -1 | grep 'OTA_')
do
	TARGET=${TARGET_PATH/OTA_/}
	gzip -r -9 -c ${TARGET_PATH} > OTA/${TARGET}.gz

	MD5=$(md5sum OTA/${TARGET}.gz | awk '{print $1}' | cut -c1-5)
	OTA_PKG=OTA-${TARGET}-${OTA_VERSION}-${MD5}.gz
	
	mv -f OTA/${TARGET}.gz OTA/${OTA_PKG}
	#if [[ ! $(sudo ls -1 OTA-OLD) =~ ${MD5} ]]
	#then
	#	mv -f OTA/${TARGET}.gz OTA/${OTA_PKG}
	#else
	#	rm -f OTA/${TARGET}.gz
	#fi
done
