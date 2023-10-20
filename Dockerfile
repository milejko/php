ARG DEBIAN_VERSION=12-slim

FROM debian:${DEBIAN_VERSION}

ARG PHP_VERSION=8.2

# ARG gives noninteractive frontend only during image build
ARG DEBIAN_FRONTEND=noninteractive

ENV APP_DIR=/app \
	PHP_VERSION=${PHP_VERSION} \
	\
	MEMORY_LIMIT=128M \
	POST_MAX_SIZE=256M \
	UPLOAD_MAX_FILESIZE=256M \
	\
	FPM_LISTEN_PORT=9000 \
	FPM_LOG_LEVEL=notice \
	FPM_PM_MAX_CHILDREN=90 \
	FPM_PM_START_SERVERS=10 \
	FPM_PM_MIN_SPARE_SERVERS=4 \
	FPM_PM_MAX_SPARE_SERVERS=16 \
	FPM_PM_MAX_REQUEST=0 \
	\
	OPCACHE_ENABLE=1 \
	OPCACHE_MEMORY_CONSUMPTION=128M \
	OPCACHE_INTERNED_STRINGS_BUFFER=16 \
	OPCACHE_JIT=on \
	OPCACHE_JIT_BUFFER_SIZE=32M

RUN apt update && \
	# installation of gettext-base (for entrypoint's envsubst), and lsb-release and wget for Ondrey Sury repository
	apt install -yq gettext-base lsb-release wget && \
	# adding Ondrey Sury repository
	wget https://packages.sury.org/php/apt.gpg -O /usr/share/keyrings/deb.sury.org-php.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php-sury.list && \
	apt update && \
	# adding php%version packages
	apt install -yq \
	php${PHP_VERSION}-cli \
	php${PHP_VERSION}-fpm \
	php${PHP_VERSION}-bcmath \
	php${PHP_VERSION}-curl \
	php${PHP_VERSION}-dom \
	php${PHP_VERSION}-intl \
	php${PHP_VERSION}-mbstring \
	php${PHP_VERSION}-zip \
	php${PHP_VERSION}-xml \
	unzip \
	zip

# https://github.com/php/php-src/blob/17baa87faddc2550def3ae7314236826bc1b1398/sapi/fpm/php-fpm.8.in#L163
STOPSIGNAL SIGQUIT

# copy fpm configuration and entrypoint
COPY --link ./etc /etc
COPY --link --chmod=755 ./docker-entrypoint.sh /docker-entrypoint.sh

# /app by default
WORKDIR ${APP_DIR}

# 9000 by default
EXPOSE ${FPM_LISTEN_PORT}

# configure & run php-fpm
ENTRYPOINT ["/docker-entrypoint.sh"]