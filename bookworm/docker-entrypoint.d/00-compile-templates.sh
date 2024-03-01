#!/bin/bash

TEMPLATE_FILES=$(find /etc/php -name "*.*.template")

for TEMPLATE_FILE_PATH in ${TEMPLATE_FILES}
do
    TARGET_PATH=$(echo ${TEMPLATE_FILE_PATH} | sed -e "s/etc\/php/etc\/php\/${PHP_VERSION}/g" | sed -e "s/\.template//g")
    TARGET_DIR=$(dirname ${TARGET_PATH})
    mkdir -p ${TARGET_DIR}
    envsubst < $TEMPLATE_FILE_PATH > $TARGET_PATH
    echo "${TARGET_PATH} compiled"
done