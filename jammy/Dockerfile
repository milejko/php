# syntax=docker/dockerfile:1.6

ARG OS_VERSION=jammy

###################
## PHP-CLI stage ##
###################
FROM ubuntu:${OS_VERSION} as cli

ARG PHP_VERSION=8.3 \
	OS_VERSION=jammy \
	DEBIAN_FRONTEND=noninteractive

ENV WORKDIR=/var/www/html \
	PHP_VERSION=${PHP_VERSION} \
	OS_VERSION=${OS_VERSION} \
	\
	ALLOW_URL_FOPEN=1 \
	\
	DEFAULT_SOCKET_TIMEOUT=60 \
	DISPLAY_ERRORS=0 \
	DISPLAY_STARTUP_ERRORS=0 \
	ERROR_REPORTING=E_ALL \
	MAX_EXECUTION_TIME=30 \
	MEMORY_LIMIT=128M \
	REALPATH_CACHE_SIZE=4096K \
	REALPATH_CACHE_TTL=120 \
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

RUN set -eux; \
	apt-get update; \
	apt-get install -yq --no-install-recommends \
		git \
		zip \
		unzip \
		curl \
		gnupg \
		ca-certificates \
		gettext-base \
	; \
	# Retrieve deb.sury.org certificates and make it visible for APT
	gpg --keyserver keyserver.ubuntu.com --recv-keys 71DAEAAB4AD4CAB6 4F4EA0AAE5267A6C; \
	gpg --output /etc/apt/trusted.gpg.d/deb-sury-php.gpg --export; \
	echo "deb https://ppa.launchpadcontent.net/ondrej/php/ubuntu/ ${OS_VERSION} main" > /etc/apt/sources.list.d/ondrey-php-ubuntu-${OS_VERSION}.list ; \
	apt-get update; \
	apt-get install -yq --no-install-recommends \
		php${PHP_VERSION}-amqp \
		php${PHP_VERSION}-apcu \
		php${PHP_VERSION}-bcmath \
		php${PHP_VERSION}-cli \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-dom \
		php${PHP_VERSION}-gd \
		php${PHP_VERSION}-intl \
		php${PHP_VERSION}-ldap \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-pdo-mysql \
    	php${PHP_VERSION}-pdo-sqlite \
		php${PHP_VERSION}-redis \
		php${PHP_VERSION}-zip \
		php${PHP_VERSION}-xdebug \
		php${PHP_VERSION}-xml \
	; \
	curl https://getcomposer.org/installer > composer-setup.php; \
	php composer-setup.php; \
	mv composer.phar /usr/bin/composer; \
	rm composer-setup.php; \
	apt-get purge --autoremove -yq \
		gnupg \
		perl \
	; \
	rm -rf /var/lib/apt/lists

COPY --link ./etc/php/cli /etc/php/cli
COPY --link ./etc/php/mods-available /etc/php/mods-available
COPY --link --chmod=755 ./docker-entrypoint.d /docker-entrypoint.d
COPY --link --chmod=755 ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR ${WORKDIR}

ENTRYPOINT [ "/docker-entrypoint.sh" ]

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
	FPM_PM_MAX_REQUESTS=0

RUN set -eux; \
	apt-get update; \
	apt-get install -yq --no-install-recommends \
		php${PHP_VERSION}-fpm \
		libfcgi-bin; \
	rm -rf /var/lib/apt/lists; \
	ln -s /usr/sbin/php-fpm${PHP_VERSION} /usr/bin/php-fpm

COPY --link ./etc/php/fpm /etc/php/fpm

# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

EXPOSE ${FPM_LISTEN_PORT}

CMD [ "/usr/bin/php-fpm" ]

######################
## PHP Apache stage ##
######################
FROM cli as apache

ENV APACHE_LISTEN_PORT=80 \
	APACHE_SERVER_NAME=localhost \
	APACHE_TIMEOUT=300 \
	APACHE_KEEPALIVE=On \
	APACHE_MAX_KEEPALIVE_REQUESTS=100 \
	APACHE_KEEPALIVE_TIMEOUT=5 \
	APACHE_LOG_LEVEL=warn

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		# https://github.com/docker-library/httpd/issues/214
		ca-certificates \
		libaprutil1-ldap \
		# https://github.com/docker-library/httpd/issues/209
		libldap-common \
		apache2 \
		libapache2-mod-php${PHP_VERSION} \
	; \
	a2enmod rewrite;\
	a2enmod headers;\
	rm -rf /etc/apache2/envvars; \
	rm -rf /etc/apache2/conf-enabled; \
	rm -rf /etc/apache2/sites-enabled; \
	rm -rf /var/www/html/*; \
	rm -rf /var/lib/apt/lists

COPY --link ./etc/php/apache2 /etc/php/apache2
COPY --link ./etc/apache2 /etc/apache2
COPY --link --chmod=755 ./usr/sbin/apache2-foreground /usr/sbin/apache2-foreground

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGTERM

EXPOSE ${APACHE_LISTEN_PORT}

# This script specifies filters out all stop signals except of TERM, KILL, STOP, HUP, QUIT, INT
# The one needs filtering is: SIGWINCH - terminal window change ie.: resize and docker attach
# K8s uses attach, causing containers running the default httpd command instant quit
# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
# https://stackoverflow.com/questions/780853/what-is-in-apache-2-a-caught-sigwinch-error
# https://github.com/docker-library/php/issues/64
CMD [ "/usr/sbin/apache2-foreground" ]
