#!/bin/sh

docker run ${IMAGE_TAG} find /usr/sbin/php-fpm${PHP_VERSION}
docker run ${IMAGE_TAG} find /usr/bin/php-fpm