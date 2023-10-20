#!/bin/sh

envsubst < /etc/php/fpm/pool.d/www.conf.tmpl        > /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
envsubst < /etc/php/mods-available/opcache.ini.tmpl > /etc/php/${PHP_VERSION}/mods-available/opcache.ini

/usr/sbin/php-fpm${PHP_VERSION}