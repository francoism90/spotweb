#!/usr/bin/env bash
set -euo pipefail

# Renumber the "spotweb" user/group to match the host's PUID/PGID, then drop
# from root down to it. The image itself is always built with UID/GID 1000;
# this is what lets one shared, prebuilt image still write correctly-owned
# files on hosts where the deploying user isn't 1000.
if [ "$(id -u)" = '0' ]; then
    PUID=${PUID:-1000}
    PGID=${PGID:-1000}

    if [ "$(id -g spotweb)" != "${PGID}" ]; then
        groupmod -o -g "${PGID}" spotweb
    fi

    if [ "$(id -u spotweb)" != "${PUID}" ]; then
        usermod -o -u "${PUID}" spotweb
    fi

    chown -R spotweb:spotweb /app /config /data

    exec gosu spotweb "$0" "$@"
fi

# Hand off to the base frankenphp image's own entrypoint, which turns the
# inherited CMD (--config /etc/frankenphp/Caddyfile --adapter caddyfile)
# into "frankenphp run ...".
exec docker-php-entrypoint "$@"
