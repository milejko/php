# syntax=docker/dockerfile:1.6

ARG OS_VERSION=bookworm-slim

## PHP-CLI stage
FROM debian:${OS_VERSION} as php-cli

ARG PHP_VERSION=8.2

ENV APP_DIR=/app \
	PHP_VERSION=${PHP_VERSION} \
	\
	MEMORY_LIMIT=-1 \
	MAX_EXECUTION_TIME=30 \
	POST_MAX_SIZE=256M \
	UPLOAD_MAX_FILESIZE=256M \
	\
	OPCACHE_ENABLE=1 \
	OPCACHE_ENABLE_CLI=0 \
	OPCACHE_MEMORY_CONSUMPTION=128M \
	OPCACHE_INTERNED_STRINGS_BUFFER=16 \
	OPCACHE_JIT=off \
	OPCACHE_JIT_BUFFER_SIZE=32M

RUN apt-get update && \
	apt-get install -yq --no-install-recommends \
		gettext-base \
		lsb-release \
		wget \
		ca-certificates \
		unzip \
		zip && \
	wget https://packages.sury.org/php/apt.gpg -O /usr/share/keyrings/deb.sury.org-php.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php-sury.list && \
	apt-get update && \
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
	rm composer-setup.php

# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

COPY --link ./etc/php/cli /etc/php/${PHP_VERSION}/cli
COPY --link ./etc/php/mods-available /etc/php/${PHP_VERSION}/mods-available
COPY --link --chmod=755 ./docker-entrypoint.d /docker-entrypoint.d
COPY --link --chmod=755 ./docker-entrypoint /docker-entrypoint

WORKDIR ${APP_DIR}

ENTRYPOINT [ "/docker-entrypoint" ]

CMD [ "php", "-a" ]

## PHP-FPM stage
FROM php-cli as php-fpm

ENV MEMORY_LIMIT=128M \
	\
	FPM_LISTEN_PORT=9000 \
	FPM_LOG_LEVEL=notice \
	FPM_PM_MAX_CHILDREN=90 \
	FPM_PM_START_SERVERS=10 \
	FPM_PM_MIN_SPARE_SERVERS=4 \
	FPM_PM_MAX_SPARE_SERVERS=16 \
	FPM_PM_MAX_REQUEST=0

RUN apt-get install -yq --no-install-recommends \
	php${PHP_VERSION}-fpm && \
	ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm

COPY --link ./etc/php/fpm /etc/php/${PHP_VERSION}/fpm

EXPOSE ${FPM_LISTEN_PORT}

CMD [ "/usr/bin/php-fpm" ]
