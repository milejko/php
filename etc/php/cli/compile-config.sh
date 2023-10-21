# PHP configuration (ie. memory_limit, upload_max_size)
envsubst < /etc/php/cli/conf.d/99-config.ini.tmpl > /etc/php/${PHP_VERSION}/cli/conf.d/99-config.ini
