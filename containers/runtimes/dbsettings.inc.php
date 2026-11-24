<?php

// Read from the environment, so the password can come from a Podman secret.
$dbsettings['engine'] = getenv('DB_ENGINE') ?: 'pdo_mysql';
$dbsettings['host'] = getenv('DB_HOST') ?: 'systemd-spotweb-mariadb';
$dbsettings['port'] = getenv('DB_PORT') ?: '3306';
$dbsettings['dbname'] = getenv('DB_DATABASE') ?: 'spotweb';
$dbsettings['user'] = getenv('DB_USERNAME') ?: 'spotweb';
$dbsettings['pass'] = getenv('DB_PASSWORD') ?: '';
