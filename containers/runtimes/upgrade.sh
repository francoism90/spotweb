#!/usr/bin/env bash
set -euo pipefail

# Creates or upgrades the database schema, users and settings. On an empty
# database, the first run creates the tables but can't save the settings yet:
# Spotweb only adds its database settings source when the settings table
# already exists. The second run saves them, and is a quick check otherwise.
php /app/bin/upgrade-db.php "$@"
php /app/bin/upgrade-db.php "$@"
