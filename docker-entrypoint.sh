#!/bin/sh

/etc/php/compile-config.sh

# Allow running commands by CMD
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

eval "$@"
