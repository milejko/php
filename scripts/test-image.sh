#!/bin/sh

set -eu;

# test default configuration
PHP_INFO_DEFAULT=$(docker run ${IMAGE_TAG} -r 'phpinfo();')

echo "${PHP_INFO_DEFAULT}" | grep "allow_url_fopen => On"
echo "${PHP_INFO_DEFAULT}" | grep "default_socket_timeout => 60"
echo "${PHP_INFO_DEFAULT}" | grep "display_errors => Off"
echo "${PHP_INFO_DEFAULT}" | grep "display_startup_errors => Off"
echo "${PHP_INFO_DEFAULT}" | grep "error_reporting => 32767"
echo "${PHP_INFO_DEFAULT}" | grep "max_execution_time => 0"
echo "${PHP_INFO_DEFAULT}" | grep "memory_limit => 128M"
echo "${PHP_INFO_DEFAULT}" | grep "realpath_cache_size => 4096K"
echo "${PHP_INFO_DEFAULT}" | grep "realpath_cache_ttl => 120"

echo "${PHP_INFO_DEFAULT}" | grep "file_uploads => On"
echo "${PHP_INFO_DEFAULT}" | grep "post_max_size => 128M"
echo "${PHP_INFO_DEFAULT}" | grep "upload_max_filesize => 128M"

echo "${PHP_INFO_DEFAULT}" | grep "opcache.enable => On"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.enable_cli => Off"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.memory_consumption => 128M"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.validate_timestamps => On"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.revalidate_freq => 2"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.max_accelerated_files => 65000"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.preload => no value"
echo "${PHP_INFO_DEFAULT}" | grep "opcache.preload_user => no value"
echo "${PHP_INFO_DEFAULT}" | grep "xdebug.ini"

# test if XDEBUG module is disabled
if echo "${PHP_INFO_DEFAULT}" | grep "xdebug.mode" ; then
    echo "XDEBUG enabled!"
    exit 1
fi

# test altered configuration (ENV)
PHP_INFO=$(docker run \
    \
    -e ALLOW_URL_FOPEN=0 \
    -e DEFAULT_SOCKET_TIMEOUT=15 \
    -e DISPLAY_ERRORS=1 \
    -e DISPLAY_STARTUP_ERRORS=1 \
    -e ERROR_REPORTING=E_NONE \
    -e MAX_EXECUTION_TIME=0 \
    -e MEMORY_LIMIT=200M \
    -e REALPATH_CACHE_SIZE=8M \
    -e REALPATH_CACHE_TTL=200 \
    \
    -e FILE_UPLOADS=0 \
    -e POST_MAX_SIZE=200M \
    -e UPLOAD_MAX_FILESIZE=200M \
    \
    -e OPCACHE_ENABLE=0 \
    -e OPCACHE_ENABLE_CLI=1 \
    -e OPCACHE_MEMORY_CONSUMPTION=200M \
    -e OPCACHE_INTERNED_STRINGS_BUFFER=22 \
    -e OPCACHE_VALIDATE_TIMESTAMPS=0 \
    -e OPCACHE_REVALIDATE_FREQ=15 \
    -e OPCACHE_PRELOAD="test.php" \
    -e OPCACHE_PRELOAD_USER="someuser" \
    -e OPCACHE_JIT=1 \
    -e OPCACHE_JIT_BUFFER_SIZE=8M \
    \
    -e XDEBUG_ENABLE=1 \
    -e XDEBUG_MODE=develop \
${IMAGE_TAG} -r 'phpinfo();')

echo "${PHP_INFO}" | grep "allow_url_fopen => Off"
echo "${PHP_INFO}" | grep "default_socket_timeout => 15"
echo "${PHP_INFO}" | grep "display_errors => STDOUT"
echo "${PHP_INFO}" | grep "display_startup_errors => On"
echo "${PHP_INFO}" | grep "error_reporting => E_NONE"
echo "${PHP_INFO}" | grep "max_execution_time => 0"
echo "${PHP_INFO}" | grep "memory_limit => 200M"
echo "${PHP_INFO}" | grep "realpath_cache_size => 8M"
echo "${PHP_INFO}" | grep "realpath_cache_ttl => 200"

echo "${PHP_INFO}" | grep "file_uploads => Off"
echo "${PHP_INFO}" | grep "post_max_size => 200M"
echo "${PHP_INFO}" | grep "upload_max_filesize => 200M"

echo "${PHP_INFO}" | grep "opcache.enable => Off"
echo "${PHP_INFO}" | grep "opcache.enable_cli => On"
echo "${PHP_INFO}" | grep "opcache.memory_consumption => 200M"
echo "${PHP_INFO}" | grep "opcache.validate_timestamps => Off"
echo "${PHP_INFO}" | grep "opcache.revalidate_freq => 15"
echo "${PHP_INFO}" | grep "opcache.max_accelerated_files => 65000"
echo "${PHP_INFO}" | grep "opcache.preload => test.php"
echo "${PHP_INFO}" | grep "opcache.preload_user => someuser"
#not compatible with PHP 7.x
#echo "${PHP_INFO}" | grep "opcache.jit => 1"
#echo "${PHP_INFO}" | grep "opcache.jit_buffer_size => 8M"
echo "${PHP_INFO}" | grep "xdebug.mode => develop"

# test docker-entrypoint.d scripts
STARTUP_MESSAGES=$(docker run ${IMAGE_TAG} bash)
echo "${STARTUP_MESSAGES}" | grep "Running docker-entrypoint.d scripts:"
echo "${STARTUP_MESSAGES}" | grep "00-compile-templates"
echo "${STARTUP_MESSAGES}" | grep "05-configure-xdebug"
echo "${STARTUP_MESSAGES}" | grep "config.ini"
echo "${STARTUP_MESSAGES}" | grep "xdebug.ini"
echo "${STARTUP_MESSAGES}" | grep "opcache.ini"
echo "${STARTUP_MESSAGES}" | grep "XDEBUG disabled"

# test php interactive mode
docker run ${IMAGE_TAG} -a | grep "Interactive"

# test composer
docker run ${IMAGE_TAG} composer -V | grep "Composer version"

# test WORKDIR
docker run ${IMAGE_TAG} pwd | grep "/var/www/html"

# test ICONV
docker run ${IMAGE_TAG} -r "echo iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', 'abc');" | grep 'abc';

# test installed modules
INSTALLED_MODULES=$(docker run ${IMAGE_TAG} -m)

echo "${INSTALLED_MODULES}" | grep "amqp"
echo "${INSTALLED_MODULES}" | grep "apcu"
echo "${INSTALLED_MODULES}" | grep "bcmath"
echo "${INSTALLED_MODULES}" | grep "calendar"
echo "${INSTALLED_MODULES}" | grep "Core"
echo "${INSTALLED_MODULES}" | grep "ctype"
echo "${INSTALLED_MODULES}" | grep "curl"
echo "${INSTALLED_MODULES}" | grep "date"
echo "${INSTALLED_MODULES}" | grep "dom"
echo "${INSTALLED_MODULES}" | grep "exif"
echo "${INSTALLED_MODULES}" | grep "FFI"
echo "${INSTALLED_MODULES}" | grep "fileinfo"
echo "${INSTALLED_MODULES}" | grep "gd"
echo "${INSTALLED_MODULES}" | grep "gettext"
echo "${INSTALLED_MODULES}" | grep "hash"
echo "${INSTALLED_MODULES}" | grep "iconv"
echo "${INSTALLED_MODULES}" | grep "igbinary"
echo "${INSTALLED_MODULES}" | grep "intl"
echo "${INSTALLED_MODULES}" | grep "json"
echo "${INSTALLED_MODULES}" | grep "ldap"
echo "${INSTALLED_MODULES}" | grep "libxml"
echo "${INSTALLED_MODULES}" | grep "mbstring"
echo "${INSTALLED_MODULES}" | grep "mysqli"
echo "${INSTALLED_MODULES}" | grep "mysqlnd"
echo "${INSTALLED_MODULES}" | grep "openssl"
echo "${INSTALLED_MODULES}" | grep "pcntl"
echo "${INSTALLED_MODULES}" | grep "pcre"
echo "${INSTALLED_MODULES}" | grep "PDO"
echo "${INSTALLED_MODULES}" | grep "pdo_mysql"
echo "${INSTALLED_MODULES}" | grep "pdo_sqlite"
echo "${INSTALLED_MODULES}" | grep "Phar"
echo "${INSTALLED_MODULES}" | grep "posix"
echo "${INSTALLED_MODULES}" | grep "readline"
echo "${INSTALLED_MODULES}" | grep "redis"
echo "${INSTALLED_MODULES}" | grep "Reflection"
echo "${INSTALLED_MODULES}" | grep "session"
echo "${INSTALLED_MODULES}" | grep "shmop"
echo "${INSTALLED_MODULES}" | grep "SimpleXML"
echo "${INSTALLED_MODULES}" | grep "sockets"
echo "${INSTALLED_MODULES}" | grep "sodium"
echo "${INSTALLED_MODULES}" | grep "SPL"
echo "${INSTALLED_MODULES}" | grep "sqlite3"
echo "${INSTALLED_MODULES}" | grep "standard"
echo "${INSTALLED_MODULES}" | grep "sysvmsg"
echo "${INSTALLED_MODULES}" | grep "sysvsem"
echo "${INSTALLED_MODULES}" | grep "sysvshm"
echo "${INSTALLED_MODULES}" | grep "tokenizer"
echo "${INSTALLED_MODULES}" | grep "xml"
echo "${INSTALLED_MODULES}" | grep "xmlreader"
echo "${INSTALLED_MODULES}" | grep "xmlwriter"
echo "${INSTALLED_MODULES}" | grep "xsl"
echo "${INSTALLED_MODULES}" | grep "Zend OPcache"
echo "${INSTALLED_MODULES}" | grep "zip"
echo "${INSTALLED_MODULES}" | grep "zlib"
