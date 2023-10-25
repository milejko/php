#!/bin/sh

IMAGE_NAME=test-image

docker run ${IMAGE_NAME} -v | grep "${PHP_VERSION}"

docker run ${IMAGE_NAME} -m | grep "bcmath" &&
docker run ${IMAGE_NAME} -m | grep "calendar" &&
docker run ${IMAGE_NAME} -m | grep "Core" &&
docker run ${IMAGE_NAME} -m | grep "ctype" &&
docker run ${IMAGE_NAME} -m | grep "curl" &&
docker run ${IMAGE_NAME} -m | grep "date" &&
docker run ${IMAGE_NAME} -m | grep "dom" &&
docker run ${IMAGE_NAME} -m | grep "exif" &&
docker run ${IMAGE_NAME} -m | grep "FFI" &&
docker run ${IMAGE_NAME} -m | grep "fileinfo" &&
docker run ${IMAGE_NAME} -m | grep "gettext" &&
docker run ${IMAGE_NAME} -m | grep "hash" &&
docker run ${IMAGE_NAME} -m | grep "iconv" &&
docker run ${IMAGE_NAME} -m | grep "intl" &&
docker run ${IMAGE_NAME} -m | grep "json" &&
docker run ${IMAGE_NAME} -m | grep "libxml" &&
docker run ${IMAGE_NAME} -m | grep "mbstring" &&
docker run ${IMAGE_NAME} -m | grep "openssl" &&
docker run ${IMAGE_NAME} -m | grep "pcntl" &&
docker run ${IMAGE_NAME} -m | grep "pcre" &&
docker run ${IMAGE_NAME} -m | grep "PDO" &&
docker run ${IMAGE_NAME} -m | grep "Phar" &&
docker run ${IMAGE_NAME} -m | grep "posix" &&
docker run ${IMAGE_NAME} -m | grep "readline" &&
docker run ${IMAGE_NAME} -m | grep "Reflection" &&
docker run ${IMAGE_NAME} -m | grep "session" &&
docker run ${IMAGE_NAME} -m | grep "shmop" &&
docker run ${IMAGE_NAME} -m | grep "SimpleXML" &&
docker run ${IMAGE_NAME} -m | grep "sockets" &&
docker run ${IMAGE_NAME} -m | grep "sodium" &&
docker run ${IMAGE_NAME} -m | grep "SPL" &&
docker run ${IMAGE_NAME} -m | grep "standard" &&
docker run ${IMAGE_NAME} -m | grep "sysvmsg" &&
docker run ${IMAGE_NAME} -m | grep "sysvsem" &&
docker run ${IMAGE_NAME} -m | grep "sysvshm" &&
docker run ${IMAGE_NAME} -m | grep "tokenizer" &&
docker run ${IMAGE_NAME} -m | grep "xml" &&
docker run ${IMAGE_NAME} -m | grep "xmlreader" &&
docker run ${IMAGE_NAME} -m | grep "xmlwriter" &&
docker run ${IMAGE_NAME} -m | grep "xsl" &&
docker run ${IMAGE_NAME} -m | grep "Zend OPcache" &&
docker run ${IMAGE_NAME} -m | grep "zip" &&
docker run ${IMAGE_NAME} -m | grep "zlib" &&
docker run ${IMAGE_NAME} -a | grep "Interactive" &&
docker run ${IMAGE_NAME} composer -V | grep "Composer version" &&
docker run -e UPLOAD_MAX_FILESIZE=200M ${IMAGE_NAME} -r 'phpinfo();' | grep "upload_max_filesize => 200M" &&
docker run -e POST_MAX_SIZE=200M ${IMAGE_NAME} -r 'phpinfo();' | grep "post_max_size => 200M" &&
docker run -e OPCACHE_MEMORY_CONSUMPTION=200M ${IMAGE_NAME} -r 'phpinfo();' | grep "opcache.memory_consumption => 200M"
