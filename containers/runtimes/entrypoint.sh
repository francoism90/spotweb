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

    # Only when the top-level directory is still owned by someone else:
    # containers start often (on each first request, and hourly for the
    # retrieve job), and /app holds all of Spotweb.
    for dir in /app /data /etc/spotweb /config; do
        if [ -d "${dir}" ] && [ "$(stat -c '%u:%g' "${dir}")" != "${PUID}:${PGID}" ]; then
            chown -R spotweb:spotweb "${dir}"
        fi
    done

    exec gosu spotweb "$0" "$@"
fi

# Seed the persisted config on first run, then point Spotweb's own
# dbsettings.inc.php path at it so writes (e.g. from install.php) land on
# the host-mounted /etc/spotweb volume instead of the container's writable
# layer. Kept out of /config and /data -- FrankenPHP/Caddy already use those
# (XDG_CONFIG_HOME/XDG_DATA_HOME) for their own autosave config and TLS state.
if [ ! -f /etc/spotweb/dbsettings.inc.php ]; then
    cp /usr/local/share/spotweb/dbsettings.inc.php.dist /etc/spotweb/dbsettings.inc.php
fi

ln -sf /etc/spotweb/dbsettings.inc.php /app/dbsettings.inc.php

# Hand off to the base frankenphp image's own entrypoint, which turns the
# inherited CMD (--config /etc/frankenphp/Caddyfile --adapter caddyfile)
# into "frankenphp run ...".
exec docker-php-entrypoint "$@"
