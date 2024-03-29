#!/bin/bash

XDEBUG_CONFIG_FILE=/etc/php/${PHP_VERSION}/mods-available/xdebug.ini

if [ ${XDEBUG_ENABLE} == '1' ] || [ ${XDEBUG_ENABLE} == 'On' ]
then 
	{ \
		echo 'zend_extension=xdebug.so'; \
		echo "xdebug.mode=${XDEBUG_MODE}"; \
	} > ${XDEBUG_CONFIG_FILE}
    echo "XDEBUG configured & enabled"
else
    echo "XDEBUG disabled"
fi;
