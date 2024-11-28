#!/bin/bash

set -u

TEST_RESULT=0

echo "Test the default configuration values"

DEFAULT_PHP_INFO=$(docker run ${IMAGE_TAG} -r 'phpinfo();')

DEFAULT_CONFIG_TEST_LINES=( 
    "allow_url_fopen => On"  
    "default_socket_timeout => 60" \
    "display_errors => Off" \
    "display_startup_errors => Off" \
    "max_execution_time => 0" \
    "memory_limit => 128M" \
    "realpath_cache_size => 4096K" \
    "realpath_cache_ttl => 120" \
    "file_uploads => On" \
    "post_max_size => 128M" \
    "upload_max_filesize => 128M" \
    "opcache.enable => On" \
    "opcache.enable_cli => Off" \
    "opcache.memory_consumption => 128M" \
    "opcache.validate_timestamps => On" \
    "opcache.revalidate_freq => 2" \
    "opcache.max_accelerated_files => 65000" \
    "opcache.preload => no value" \
    "opcache.preload_user => no value" \
    "xdebug.ini" \
    "allow_url_fopen => On" \
)

for TEST_ITEM in ${!DEFAULT_CONFIG_TEST_LINES[*]}; do
    TEST_ITEM_STR="${DEFAULT_CONFIG_TEST_LINES[$TEST_ITEM]}"
    CONFIG_KEY="${TEST_ITEM_STR%=*}"

    if  ! echo "${DEFAULT_PHP_INFO}" | grep "${TEST_ITEM_STR}" --quiet ; then
        REAL_PARAMETER_VALUE=$( echo "${DEFAULT_PHP_INFO}" | grep -e "^${CONFIG_KEY}" )
        echo -e "[${0}] FAILED for ${CONFIG_KEY} \texpected: [${TEST_ITEM_STR}] \tgot: [${REAL_PARAMETER_VALUE}]"
        TEST_RESULT=1
    fi
done

echo ""
echo "Test if XDEBUG module is disabled by default"
if echo "${DEFAULT_PHP_INFO}" | grep "xdebug.mode" ; then
    echo "XDEBUG enabled FAILED"
    TEST_RESULT=9
fi

echo ""
echo "Test altered configuration (ENV) "
ALTERED_PHP_INFO=$(docker run \
    \
    -e ALLOW_URL_FOPEN=0 \
    -e DEFAULT_SOCKET_TIMEOUT=15 \
    -e DISPLAY_ERRORS=1 \
    -e DISPLAY_STARTUP_ERRORS=1 \
    -e ERROR_REPORTING=E_NONE \
    -e MAX_EXECUTION_TIME=0 \
    -e MEMORY_LIMIT=200M \
    -e REALPATH_CACHE_SIZE=6M \
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

ALTERED_CONFIG_TEST_LINES=(
"allow_url_fopen => Off" \
"default_socket_timeout => 15" \
"display_errors => STDOUT" \
"display_startup_errors => On" \
"error_reporting => E_NONE" \
"max_execution_time => 0" \
"memory_limit => 200M" \
"realpath_cache_size => 6M" \
"realpath_cache_ttl => 200" \
"file_uploads => Off" \
"post_max_size => 200M" \
"upload_max_filesize => 200M" \
"opcache.enable => Off" \
"opcache.enable_cli => On" \
"opcache.memory_consumption => 200M" \
"opcache.validate_timestamps => Off" \
"opcache.revalidate_freq => 15" \
"opcache.max_accelerated_files => 65000" \
"opcache.preload => test.php" \
"opcache.preload_user => someuser" \
#"opcache.jit => 1" #not compatible with PHP 7.x \
#"opcache.jit_buffer_size => 8M" #not compatible with PHP 7.x \
"xdebug.mode => develop" \
)

for TEST_ITEM in ${!ALTERED_CONFIG_TEST_LINES[*]}; do
    TEST_ITEM_STR="${ALTERED_CONFIG_TEST_LINES[$TEST_ITEM]}"
    CONFIG_KEY="${TEST_ITEM_STR%=*}"

    if  ! echo "${ALTERED_PHP_INFO}" | grep "${TEST_ITEM_STR}" --quiet ; then
        REAL_PARAMETER_VALUE=$( echo "${ALTERED_PHP_INFO}" | grep -e "^${CONFIG_KEY}" )
        echo -e "[${0}] FAILED for ${CONFIG_KEY} \texpected: [${TEST_ITEM_STR}] \tgot: [${REAL_PARAMETER_VALUE}]"
        TEST_RESULT=7
    fi
done

echo ""
echo "Test docker-entrypoint.d scripts"

STARTUP_MESSAGES=$(docker run  ${IMAGE_TAG} bash) 

SCRIPTS=("Running docker-entrypoint.d scripts:" \
    "00-compile-templates" \
    "05-configure-xdebug" \
    "config.ini" \
    "xdebug.ini" \
    "opcache.ini" \
    "XDEBUG disabled" \
)

# echo "STR:>${STARTUP_MESSAGES}<"
for TEST_ITEM in ${!SCRIPTS[*]}; do
    TEST_ITEM_STR="${SCRIPTS[$TEST_ITEM]}"
    CONFIG_KEY="${TEST_ITEM_STR%=*}"
    # echo "testing: ${TEST_ITEM_STR}" 
    if  ! echo "${STARTUP_MESSAGES}" | grep "${TEST_ITEM_STR}" --quiet ; then
        REAL_PARAMETER_VALUE=$( echo "${STARTUP_MESSAGES}" | grep -e "^${CONFIG_KEY}" )
        echo -e "[${0}] FAILED for ${CONFIG_KEY} \texpected: [${TEST_ITEM_STR}] \tgot: [${REAL_PARAMETER_VALUE}]"
        TEST_RESULT=8
    fi
done

echo ""
echo "Test various tools"

# test php interactive mode
docker run ${IMAGE_TAG} -a | grep "Interactive" --quiet || ( TEST_RESULT=2 && echo "interactive mode FAILED" )
 
# test composer
docker run ${IMAGE_TAG} composer -V | grep "Composer version" --quiet  || ( TEST_RESULT=3 && echo "composer version FAILED" )

# test WORKDIR
docker run ${IMAGE_TAG} pwd | grep "/var/www/html" --quiet  || ( TEST_RESULT=4 && echo "Workdir FAILED" )

# test ICONV
docker run ${IMAGE_TAG} -r "echo iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', 'abc');" | grep 'abc' --quiet || ( TEST_RESULT=5 && echo "iconv FAILED" )

echo ""
echo "Test installed modules "
INSTALLED_MODULES=$(docker run ${IMAGE_TAG} -m)

MODULES=("amqp" \
    "apcu" \
    "bcmath" \
    "calendar" \
    "Core" \
    "ctype" \
    "curl" \
    "date" \
    "dom" \
    "exif" \
    "FFI" \
    "fileinfo" \
    "gd" \
    "gettext" \
    "hash" \
    "iconv" \
    "igbinary" \
    "intl" \
    "json" \
    "ldap" \
    "libxml" \
    "mbstring" \
    "mysqli" \
    "mysqlnd" \
    "openssl" \
    "pcntl" \
    "pcre" \
    "PDO" \
    "pdo_mysql" \
    "pdo_sqlite" \
    "Phar" \
    "posix" \
    "readline" \
    "redis" \
    "Reflection" \
    "session" \
    "shmop" \
    "SimpleXML" \
    "sockets" \
    "sodium" \
    "SPL" \
    "sqlite3" \
    "standard" \
    "sysvmsg" \
    "sysvsem" \
    "sysvshm" \
    "tokenizer" \
    "xml" \
    "xmlreader" \
    "xmlwriter" \
    "xsl" \
    "Zend OPcache" \
    "zip" \
    "zlib" \
)

for TEST_ITEM in ${!MODULES[*]}; do
    TEST_ITEM_STR="${MODULES[$TEST_ITEM]}"
    CONFIG_KEY="${TEST_ITEM_STR%=*}"

    if  ! echo "${INSTALLED_MODULES}" | grep "${TEST_ITEM_STR}" --quiet ; then
        REAL_PARAMETER_VALUE=$( echo "${MODULES}" | grep -e "^${CONFIG_KEY}" )
        echo -e "[${0}] FAILED for ${CONFIG_KEY} \texpected: [${TEST_ITEM_STR}] \tgot: [${REAL_PARAMETER_VALUE}]"
        TEST_RESULT=6
    fi
done

echo ""
echo "---------------------"
echo "Overall result is: ${TEST_RESULT}"
echo ""
exit $TEST_RESULT