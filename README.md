# Spotweb

This a example of a Spotweb docker setup using Podman and FrankenPHP.

## Install

At first install, enter the container:

```bash
podman exec -ti systemd-spotweb /bin/bash
```

Remove the current `dbsettings.inc.php`:

```bash
rm -rf dbsettings.inc.php
```

After installing using <http://localhost:8080/install.php>, sync the new `dbsettings.inc.php` to `containers/runtimes/dbsettings.inc.php`:

```bash
cat dbsettings.inc.php
```

Restart the containers:

```bash
systemctl --user restart spotweb
```

## Usage

After install, it should be available at <http://localhost:8080/>.
