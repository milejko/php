PHP Docker image
================
Debian-slim based, open source, Docker image with ease of configuration in the heart.

### Core features ###
* Clean way of configuration: using ENVs during runtime (ie. MEMORY_LIMIT, UPLOAD_MAX_FILESIZE and more...)
* PHP and default modules are installed from Debian packages
* Composer out of the box
* Other PHP modules can be easily installed with `_apt install phpX.Y-module_`

### Example uses ###
Displaying phpinfo() in the terminal
```
docker run milejko/php:8.2-cli -r 'phpinfo();'
```
Running composer
```
docker run milejko/php:8.2-cli composer
```
Running phpinfo() website using built-in PHP server
`Dockerfile`
```
FROM milejko/php:8.2-cli
RUN echo "<?php phpinfo();" > /app/index.php
EXPOSE 8080
CMD [ "php", "-S", "0.0.0.0:8080" ]
```
Build your image and execute it, using:
```
docker build -t phpinfo-http .
docker run --publish 127.0.0.1:8080:8080 phpinfo-http
```
For further details, instructions and examples visit our Docker hub: [https://hub.docker.com/r/milejko/php](https://hub.docker.com/r/milejko/php)

Supported versions: 7.4, 8.0, 8.1, 8.2, 8.3-RC<br>
Supported architectures: linux/amd64, linux/arm64

Enjoy! By [Mariusz Miłejko](https://github.com/milejko)
