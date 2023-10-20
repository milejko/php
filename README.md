PHP-FPM (+CLI) Docker image
===========================

Debian-slim based, open source, lightweight, Docker image with ease of configuration in the heart.  
Using the best quality [Ondřej Surý's](https://github.com/oerdnj) PHP packages for stability and easy access to all PHP extensions.  
Dockerfile can be seen here: [https://github.com/milejko/php-fpm](https://github.com/milejko/php-fpm/blob/main/Dockerfile).  
Supported versions: 7.4, 8.0, 8.1, 8.2  

Example #1: Run a regular PHP-FPM server
----------------------------------------

The example below shows a typical php-fpm:8.2 image usage.

`Dockerfile`

ARG PHP\_VERSION=8.2
FROM milejko/php-fpm:${PHP\_VERSION}

Build your image and execute it, using:

docker build -t phpinfo-fpm .
docker run --env FPM\_LOG\_LEVEL=debug --publish 127.0.0.1:9000:9000 phpinfo-fpm

Now your PHP-FPM container is up and ready for connections, also take a note that in this example FPM\_LOG\_LEVEL is set to "debug".  
It is not very useful without a PHP application mounted inside /app directory, and nginx with `fastcgi_pass 127.0.0.1:9000;` in front of it, but it definitely runs.

Example #2: Display phpinfo() in the terminal
---------------------------------------------

In this example by modifying ENTRYPOINT we get .php file executed with PHP-CLI

`Dockerfile`

ARG PHP\_VERSION=8.2
FROM milejko/php-fpm:${PHP\_VERSION}
RUN echo "<?php phpinfo();" > /app/index.php
CMD \[ "php", "index.php" \]

Build your image and execute it, using:

docker build -t phpinfo-cli .
docker run phpinfo-cli

You should be able to see the phpinfo() page in your terminal.

Example #3: Display phpinfo() website
-------------------------------------

PHP provides a built-in webserver. In the following example we'll create such server.

`Dockerfile`

ARG PHP\_VERSION=8.2
FROM milejko/php-fpm:${PHP\_VERSION}
RUN echo "<?php phpinfo();" > /app/index.php
EXPOSE 8080
CMD \[ "php", "-S", "0.0.0.0:8080" \]

Build your image and execute it, using:

docker build -t phpinfo-http .
docker run --publish 127.0.0.1:8080:8080 phpinfo-http

Now after visiting [http://127.0.0.1:8080](http://127.0.0.1:8080) in your favourite browser, phpinfo() page should be visible.

Adding more extensions
----------------------

In this example popular PDO-MYSQL, REDIS and AMQP extensions will be added.  
First create your own Dockerfile, with this code:

`Dockerfile`

ARG PHP\_VERSION=8.2
FROM milejko/php-fpm:${PHP\_VERSION}
RUN apt update && apt install -y \\
    php${PHP\_VERSION}-amqp \\
    php${PHP\_VERSION}-pdo-mysql \\
    php${PHP\_VERSION}-redis

Available environmental values
------------------------------

To tweak those values just pass them by adding --env ENV=value during runtime.

APP\_DIR=/app
MAX\_EXECUTION\_TIME=30
MEMORY\_LIMIT=128M
POST\_MAX\_SIZE=256M
UPLOAD\_MAX\_FILESIZE=256M

FPM\_LISTEN\_PORT=9000
FPM\_LOG\_LEVEL=notice
FPM\_PM\_MAX\_CHILDREN=90
FPM\_PM\_START\_SERVERS=10
FPM\_PM\_MIN\_SPARE\_SERVERS=4
FPM\_PM\_MAX\_SPARE\_SERVERS=16
FPM\_PM\_MAX\_REQUEST=0

OPCACHE\_ENABLE=1
OPCACHE\_MEMORY\_CONSUMPTION=128M
OPCACHE\_INTERNED\_STRINGS\_BUFFER=16
OPCACHE\_JIT=on
OPCACHE\_JIT\_BUFFER\_SIZE=32M

  
Enjoy! By [Mariusz Miłejko](https://github.com/milejko)