#!/bin/sh

#filling php-fpm pool config
envsubst < /etc/php/fpm/pool.d/www.conf.tmpl        > /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
#configuring opcache module
envsubst < /etc/php/mods-available/opcache.ini.tmpl > /etc/php/${PHP_VERSION}/mods-available/opcache.ini

#additional PHP configuration (ie. memory_limit, upload_max_size)
envsubst < /etc/php/mods-available/config.ini.tmpl  > /etc/php/${PHP_VERSION}/cli/conf.d/99-config.ini
envsubst < /etc/php/mods-available/config.ini.tmpl  > /etc/php/${PHP_VERSION}/fpm/conf.d/99-config.ini

eval $@