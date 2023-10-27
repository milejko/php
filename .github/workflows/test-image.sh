#!/bin/sh

PHP_INFO=$(docker run \
    -e UPLOAD_MAX_FILESIZE=200M \
    -e MAX_EXECUTION_TIME=60 \
    -e POST_MAX_SIZE=200M \
    -e OPCACHE_ENABLE=0 \
    -e OPCACHE_ENABLE_CLI=1 \
    -e OPCACHE_MEMORY_CONSUMPTION=200M \
    -e OPCACHE_INTERNED_STRINGS_BUFFER=22 \
    -e OPCACHE_JIT=1 \
    -e OPCACHE_JIT_BUFFER_SIZE=16M \
${IMAGE_TAG} -r 'phpinfo();')

echo "${PHP_INFO}" | grep "upload_max_filesize => 200M"
echo "${PHP_INFO}" | grep "max_execution_time =>"
echo "${PHP_INFO}" | grep "post_max_size => 200M"
echo "${PHP_INFO}" | grep "opcache.enable => Off"
echo "${PHP_INFO}" | grep "opcache.enable_cli => On"
echo "${PHP_INFO}" | grep "opcache.memory_consumption => 200M"
echo "${PHP_INFO}" | grep "opcache.interned_strings_buffer => 22"
echo "${PHP_INFO}" | grep "opcache.jit => 1"
echo "${PHP_INFO}" | grep "opcache.jit_buffer_size => 16M"

docker run ${IMAGE_TAG} -a | grep "Interactive"

docker run ${IMAGE_TAG} composer -V | grep "Composer version"
docker run ${IMAGE_TAG} pwd | grep "/app"

INSTALLED_MODULES=$(docker run ${IMAGE_TAG} -m)

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
echo "${INSTALLED_MODULES}" | grep "gettext"
echo "${INSTALLED_MODULES}" | grep "hash"
echo "${INSTALLED_MODULES}" | grep "iconv"
echo "${INSTALLED_MODULES}" | grep "intl"
echo "${INSTALLED_MODULES}" | grep "json"
echo "${INSTALLED_MODULES}" | grep "libxml"
echo "${INSTALLED_MODULES}" | grep "mbstring"
echo "${INSTALLED_MODULES}" | grep "openssl"
echo "${INSTALLED_MODULES}" | grep "pcntl"
echo "${INSTALLED_MODULES}" | grep "pcre"
echo "${INSTALLED_MODULES}" | grep "PDO"
echo "${INSTALLED_MODULES}" | grep "Phar"
echo "${INSTALLED_MODULES}" | grep "posix"
echo "${INSTALLED_MODULES}" | grep "readline"
echo "${INSTALLED_MODULES}" | grep "Reflection"
echo "${INSTALLED_MODULES}" | grep "session"
echo "${INSTALLED_MODULES}" | grep "shmop"
echo "${INSTALLED_MODULES}" | grep "SimpleXML"
echo "${INSTALLED_MODULES}" | grep "sockets"
echo "${INSTALLED_MODULES}" | grep "sodium"
echo "${INSTALLED_MODULES}" | grep "SPL"
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
