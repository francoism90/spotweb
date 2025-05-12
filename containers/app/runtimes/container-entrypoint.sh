#!/usr/bin/env bash

set -e

if [ "$SPOTWEB_USER" != "root" ] && [ "$SPOTWEB_USER" != "docker" ]; then
    echo "You should set SPOTWEB_USER to either 'docker' or 'root'."
    exit 1
fi

if [ ! -z "$UID" ]; then
    usermod -u $UID docker
fi

if [ "$1" != "" ]; then
    exec "$@"
else
    exec $SPOTWEB_COMMAND
fi
