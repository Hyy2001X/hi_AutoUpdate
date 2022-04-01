#!/bin/bash


WORK="${GITHUB_WORKSPACE}"

mkdir -p output

ls -1 | grep 'OTA_'
for TARGET in $(ls ls -1 | grep 'OTA_')
do
	echo ${TARGET}
done
