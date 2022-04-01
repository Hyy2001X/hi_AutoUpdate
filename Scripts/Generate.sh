#!/bin/bash


WORK="${GITHUB_WORKSPACE}"

mkdir -p output

for TARGET in $(ls -1 | grep 'OTA_')
do
	echo ${TARGET}
done
