# PHP configuration (ie. memory_limit, upload_max_size)
envsubst < /etc/php/fpm/conf.d/99-config.ini.tmpl > /etc/php/${PHP_VERSION}/fpm/conf.d/99-config.ini

# Opcache Module configuration
envsubst < /etc/php/fpm/conf.d/10-opcache.ini.tmpl > /etc/php/${PHP_VERSION}/fpm/conf.d/10-opcache.ini

# PHP-FPM [www] pool configuration
envsubst < /etc/php/fpm/pool.d/www.conf.tmpl > /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf
