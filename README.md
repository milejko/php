PHP Docker image
================
PHP-FPM, CLI Docker image with ease of configuration in the heart.
Offering Debian Slim base, Ubuntu, as well as minimalistic Alpine.
New images are deployed to Docker Hub twice per month.

### Core features ###
* Clean way of configuration: using ENVs during runtime (ie. MEMORY_LIMIT, UPLOAD_MAX_FILESIZE and more...)
* PHP and default modules are installed from stable Debian/Ubuntu/Alpine packages
* Easily customizable entrypoint - implemented "/docker-entrypoint.d/" pattern
* Composer tool out of the box
* Other PHP modules can be easily installed with `apt install phpX.Y-module` or `apk add phpXY-module` (Alpine)

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

Supported base images: Debian Bookworm (Slim), Ubuntu Jammy, Alpine 3<br>
Supported versions: 7.4, 8.0, 8.1, 8.2, 8.3-RC<br>
Supported architectures: linux/amd64, linux/arm64, linux/arm/v7
