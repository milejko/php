PHP Docker image
================
highly configurable, and extendable with apt
--------------------------------------------
Debian-slim based, open source, Docker image with ease of configuration in the heart.

### Core features ###
* Clean way of configuration: using ENVs during runtime (ie. MEMORY_LIMIT, UPLOAD_MAX_FILESIZE and more...)
* PHP and default modules are installed from Debian packages
* Composer out of the box
* Other PHP modules can be easily installed with `_apt install phpX.Y-module_`

For further details, instructions and examples visit:
Dockerhub: [https://hub.docker.com/r/milejko/php](https://hub.docker.com/r/milejko/php)

### Example uses ###
Displaying phpinfo() in the terminal
```
docker run milejko/php:8.2-cli -r 'phpinfo();'
```

Running composer
```
docker run milejko/php:8.2-cli composer
```

Supported versions: 7.4, 8.0, 8.1, 8.2, 8.3-RC
Supported architectures: linux/amd64, linux/arm64

Enjoy! By [Mariusz Miłejko](https://github.com/milejko)
