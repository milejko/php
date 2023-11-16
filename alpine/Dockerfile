# syntax=docker/dockerfile:1.6

ARG OS_VERSION=3.18

###################
## PHP-CLI stage ##
###################
FROM alpine:${OS_VERSION} as cli

ARG PHP_VERSION=8.2

ENV WORKDIR=/var/www/html \
	PHP_VERSION=${PHP_VERSION} \
	\
	ALLOW_URL_FOPEN=1 \
	DEFAULT_SOCKET_TIMEOUT=60 \
	DISPLAY_ERRORS=0 \
	DISPLAY_STARTUP_ERRORS=0 \
	ERROR_REPORTING=E_ALL \
	MAX_EXECUTION_TIME=30 \
	MEMORY_LIMIT=128M \
	\
	FILE_UPLOADS=1 \	
	POST_MAX_SIZE=128M \
	UPLOAD_MAX_FILESIZE=128M \
	\
	OPCACHE_ENABLE=1 \
	OPCACHE_ENABLE_CLI=0 \
	OPCACHE_MEMORY_CONSUMPTION=128M \
	OPCACHE_INTERNED_STRINGS_BUFFER=16 \
	OPCACHE_VALIDATE_TIMESTAMPS=1 \
	OPCACHE_REVALIDATE_FREQ=2 \
	OPCACHE_PRELOAD= \
	OPCACHE_PRELOAD_USER= \
	OPCACHE_JIT=tracing \
	OPCACHE_JIT_BUFFER_SIZE=0 \
	\
	XDEBUG_ENABLE=0 \
	XDEBUG_MODE=off

# Debian compatible user (www-data)
RUN set -x; \
	addgroup -g 82 -S www-data; \
	adduser -u 82 -D -S -G www-data www-data && exit 0; exit 1

# Create ENV with PHP version without a dot (ie. 8.2 -> 82)
RUN	set -eux; \
	export PHP_PACKAGE_VERSION=${PHP_VERSION/./}; \
	apk update; \
	apk add --no-cache \
		bash \
		shadow \
		gettext \
		wget \
		ca-certificates \
		unzip \
		zip \
		php${PHP_PACKAGE_VERSION} \
		php${PHP_PACKAGE_VERSION}-bcmath \
		php${PHP_PACKAGE_VERSION}-calendar \
		php${PHP_PACKAGE_VERSION}-common \
		php${PHP_PACKAGE_VERSION}-ctype \
		php${PHP_PACKAGE_VERSION}-curl \
		php${PHP_PACKAGE_VERSION}-dom \
		php${PHP_PACKAGE_VERSION}-exif \
		php${PHP_PACKAGE_VERSION}-ffi \
		php${PHP_PACKAGE_VERSION}-fileinfo \
		php${PHP_PACKAGE_VERSION}-gd \
		php${PHP_PACKAGE_VERSION}-gettext \
		php${PHP_PACKAGE_VERSION}-iconv \
		php${PHP_PACKAGE_VERSION}-intl \
		php${PHP_PACKAGE_VERSION}-ldap \
		php${PHP_PACKAGE_VERSION}-mbstring \
		php${PHP_PACKAGE_VERSION}-mysqli \
		php${PHP_PACKAGE_VERSION}-mysqlnd \
		php${PHP_PACKAGE_VERSION}-openssl \
		php${PHP_PACKAGE_VERSION}-opcache \
		php${PHP_PACKAGE_VERSION}-pdo_sqlite \
		php${PHP_PACKAGE_VERSION}-pdo_mysql \
		php${PHP_PACKAGE_VERSION}-pecl-amqp \
		php${PHP_PACKAGE_VERSION}-pecl-apcu \
		php${PHP_PACKAGE_VERSION}-pecl-redis \
		php${PHP_PACKAGE_VERSION}-pcntl \
		php${PHP_PACKAGE_VERSION}-phar \
		php${PHP_PACKAGE_VERSION}-posix \
		php${PHP_PACKAGE_VERSION}-session \
		php${PHP_PACKAGE_VERSION}-shmop \
		php${PHP_PACKAGE_VERSION}-simplexml \
		php${PHP_PACKAGE_VERSION}-sqlite3 \
		php${PHP_PACKAGE_VERSION}-sockets \
		php${PHP_PACKAGE_VERSION}-sodium \
		php${PHP_PACKAGE_VERSION}-sysvmsg \
		php${PHP_PACKAGE_VERSION}-sysvsem \
		php${PHP_PACKAGE_VERSION}-sysvshm \
		php${PHP_PACKAGE_VERSION}-tokenizer \
		php${PHP_PACKAGE_VERSION}-xdebug \
		php${PHP_PACKAGE_VERSION}-xml \
		php${PHP_PACKAGE_VERSION}-xmlreader \
		php${PHP_PACKAGE_VERSION}-xmlwriter \
		php${PHP_PACKAGE_VERSION}-xsl \
		php${PHP_PACKAGE_VERSION}-zip
	
# fixing built-in iconv translit problem
# https://github.com/docker-library/php/issues/1121
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ gnu-libiconv=1.15-r3

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# fixing variable PHP binary name ie. linking /usr/bin/php82 to /usr/bin/php
RUN	export PHP_PACKAGE_VERSION=${PHP_VERSION/./}; \
	if [ -f "/usr/bin/php" ]; \
		then echo "PHP BIN exist"; \
		else ln -s "/usr/bin/php${PHP_PACKAGE_VERSION}" "/usr/bin/php"; \
	fi;

RUN	wget https://getcomposer.org/installer -O composer-setup.php; \
 	php composer-setup.php; \
 	mv composer.phar /usr/bin/composer; \
 	rm composer-setup.php; \
	apk del wget

COPY --link ./etc/php /etc/php
COPY --link --chmod=755 ./docker-entrypoint.d /docker-entrypoint.d
COPY --link --chmod=755 ./docker-entrypoint /docker-entrypoint

WORKDIR ${WORKDIR}

ENTRYPOINT [ "/docker-entrypoint" ]

CMD [ "php", "-a" ]

###################
## PHP-FPM stage ##
###################
FROM cli as fpm

ENV FPM_LISTEN_PORT=9000 \
	FPM_LOG_LEVEL=notice \
	FPM_PM_MAX_CHILDREN=90 \
	FPM_PM_START_SERVERS=10 \
	FPM_PM_MIN_SPARE_SERVERS=4 \
	FPM_PM_MAX_SPARE_SERVERS=16 \
	FPM_PM_MAX_REQUEST=0

RUN export PHP_PACKAGE_VERSION=${PHP_VERSION/./}; \
	apk add --no-cache \
		php${PHP_PACKAGE_VERSION}-fpm \
	; \
	ln -s /usr/sbin/php-fpm${PHP_PACKAGE_VERSION} /usr/bin/php-fpm

# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE ${FPM_LISTEN_PORT}

CMD [ "/usr/bin/php-fpm", "--nodaemonize" ]

######################
## PHP Apache stage ##
######################
FROM cli as apache

ENV APACHE_LISTEN_PORT=80

RUN set -eux; \
	export PHP_PACKAGE_VERSION=${PHP_VERSION/./}; \
	apk add --no-cache \
		apache2 \
		php${PHP_PACKAGE_VERSION}-apache2 \
	; \
	rm -rf ${WORKDIR}/*; \
	rm -rf /etc/apache2/conf.d/default.conf; \
	rm -rf /etc/apache2/conf.d/userdir.conf; \
	echo "<?php phpinfo();" > ${WORKDIR}/index.php

COPY --link ./etc/apache2 /etc/apache2

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

EXPOSE ${APACHE_LISTEN_PORT}

CMD [ "httpd", "-DFOREGROUND" ]
