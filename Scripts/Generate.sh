#!/bin/bash

WORK="${GITHUB_WORKSPACE}"
OTA_VERSION=$(date +%Y%m%d%H%M%S)

mkdir -p OTA

for TARGET in $(ls -1 | grep 'OTA_')
do
	TARGET=${TARGET/OTA_/}
	gzip -9 -c ${TARGET} > OTA/${TARGET}.gz

	MD5=$(md5sum OTA/${TARGET}.gz | awk '{print $1} | cut -c1-5')
	OTA_PKG=${TARGET}-${OTA_VERSION}-${MD5}.gz

	mv -f OTA/${TARGET}.gz OTA/${OTA_PKG}
done
