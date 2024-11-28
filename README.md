# PHP Docker image
[![Latest Version](https://img.shields.io/github/release/milejko/php.svg)](https://github.com/milejko/php)
[![GitHub Actions CI](https://github.com/milejko/php/actions/workflows/ci.yml/badge.svg)](https://github.com/milejko/php/actions/workflows/ci.yml)
[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

PHP Docker image with flexibility, and easy configuration in the heart.<br>
Offering Debian Slim, Ubuntu, as well as minimalistic Alpine 3 base, each with three PHP modes: CLI, FPM and Apache.
New images are deployed to Docker Hub twice per month.

### Core features ###
* Clean way of configuration: using ENVs during runtime (ie. MEMORY_LIMIT, UPLOAD_MAX_FILESIZE and more...)
* PHP and default modules are installed from stable Debian/Ubuntu/Alpine packages
* Easily customizable entrypoint - implemented "/docker-entrypoint.d/" pattern
* Composer tool out of the box
* Other PHP modules can be easily installed with `apt install phpX.Y-module` or `apk add phpXY-module` (Alpine)

### Example uses ###
Display PHP version in the terminal
```
docker run milejko/php:8.2-cli -v
```
Execute composer command (version info)
```
docker run milejko/php:8.2-cli composer -V
```

Show phpinfo() using built-in PHP server
`Dockerfile`
```
FROM milejko/php:8.2-cli
RUN echo "<?php phpinfo();" > /var/www/html/index.php
EXPOSE 8080
CMD [ "php", "-S", "0.0.0.0:8080" ]
```

Build your image and execute it, using:
```
docker build -t phpinfo-http .
docker run --publish 127.0.0.1:8080:8080 phpinfo-http
```

Show phpinfo() using Apache server
`Dockerfile`
```
FROM milejko/php:8.2-apache
RUN echo "<?php phpinfo();" > /var/www/html/index.php
```

Build your image and execute it, using:
```
docker build -t phpinfo-apache .
docker run --publish 127.0.0.1:8080:80 phpinfo-apache
```

Now you can visit: [http://127.0.0.1:8080](http://127.0.0.1:8080) in your favorite browser.
<br>
For further details, instructions and more examples, visit our Docker hub: [https://hub.docker.com/r/milejko/php](https://hub.docker.com/r/milejko/php)

OS choice: Debian Bookworm (Slim), Ubuntu Noble, Ubuntu Jammy, Alpine 3<br>
Image variants: CLI, PHP-FPM, Apache<br>
PHP versions: 7.4, 8.0, 8.1, 8.2, 8.3<br>
Platforms: linux/amd64, linux/arm64, linux/arm/v7
