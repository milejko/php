#!/bin/bash

set -eu;

echo "Running docker-entrypoint.d scripts:"
for entrypoint_part_script in /docker-entrypoint.d/*; do
  echo "[${entrypoint_part_script}]:"
  bash "${entrypoint_part_script}"
done

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php "$@"
fi

exec "$@"