# syntax=docker/dockerfile:1.6

ARG OS_VERSION=jammy

## PHP-CLI stage
FROM ubuntu:${OS_VERSION} as cli

ARG PHP_VERSION=8.2

ENV WORKDIR=/var/www/html \
	PHP_VERSION=${PHP_VERSION} \
	\
	ALLOW_URL_FOPEN=1 \
	\
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
	OPCACHE_JIT_BUFFER_SIZE=0

RUN apt-get update && \
	apt-get install -yq --no-install-recommends \
		gettext-base \
		software-properties-common \
		gnupg \
		wget \
		unzip \
		zip && \
	add-apt-repository ppa:ondrej/php -y && \
	apt-get install -yq --no-install-recommends \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-bcmath \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-dom \
		php${PHP_VERSION}-intl \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-zip \
		php${PHP_VERSION}-xml && \
	wget https://getcomposer.org/installer -O composer-setup.php && \
	php composer-setup.php && \
	mv composer.phar /usr/bin/composer && \
	rm composer-setup.php && \
	apt-get purge --autoremove -yq \
		software-properties-common \
		gnupg \
		wget 

COPY --link ./etc/php/cli /etc/php/cli
COPY --link ./etc/php/mods-available /etc/php/mods-available
COPY --link --chmod=755 ./docker-entrypoint.d /docker-entrypoint.d
COPY --link --chmod=755 ./docker-entrypoint /docker-entrypoint

WORKDIR ${WORKDIR}

ENTRYPOINT [ "/docker-entrypoint" ]

CMD [ "php", "-a" ]

## PHP-FPM stage
FROM cli as fpm

ENV FPM_LISTEN_PORT=9000 \
	FPM_LOG_LEVEL=notice \
	FPM_PM_MAX_CHILDREN=90 \
	FPM_PM_START_SERVERS=10 \
	FPM_PM_MIN_SPARE_SERVERS=4 \
	FPM_PM_MAX_SPARE_SERVERS=16 \
	FPM_PM_MAX_REQUEST=0

RUN apt-get install -yq --no-install-recommends \
	php${PHP_VERSION}-fpm && \
	ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm

COPY --link ./etc/php/fpm /etc/php/fpm

# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE ${FPM_LISTEN_PORT}

CMD [ "/usr/bin/php-fpm" ]
