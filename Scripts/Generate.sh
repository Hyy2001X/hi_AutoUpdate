#!/bin/bash

REPO=https://github.com/$1
MODE=$2
WORK=${GITHUB_WORKSPACE}
OTA_VERSION=$(date +%Y%m%d%H%M%S)

echo "Commit: ${GITHUB_SHA}

===============================
$(git show ${GITHUB_SHA} | grep 'diff --' | awk '{print $3}')
===============================
"
mkdir -p OTA

for TARGET_PATH in $(ls -1 | grep 'OTA_')
do
	TARGET=${TARGET_PATH/OTA_/}
	echo ${OTA_VERSION} > ${TARGET_PATH}/nasversion
	tar -zcvf OTA/${TARGET}.tar.gz ${TARGET_PATH} > /dev/null 2>&1
	MD5=$(md5sum OTA/${TARGET}.tar.gz | awk '{print $1}' | cut -c1-5)
	OTA_PKG=OTA-${TARGET}-${OTA_VERSION}-${MD5}.tar.gz

	if [[ $(git show ${GITHUB_SHA} | grep 'diff --' | awk '{print $3}') =~ "${TARGET_PATH}/" || ${MODE} == true ]]
	then
		echo "${TARGET}: Generating OTA version ${OTA_VERSION} ..."
		mv -f OTA/${TARGET}.tar.gz OTA/${OTA_PKG}
		echo "OTA Package: ${OTA_PKG}"
	else
		echo "${TARGET}: Nothing to be generated"
		rm -f OTA/${TARGET}.tar.gz
	fi
done
