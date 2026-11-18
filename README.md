# Spotweb

This a example of a Spotweb docker setup using Podman and FrankenPHP.

## Disclaimer

This setup is intended for locating abandonware — software (e.g. old games)
whose licenses have expired or are no longer maintained or enforced. I'm not
responsible for the content indexed or how this instance is used.

## Install

### With Pods

In [Pods](https://github.com/foxws/pods), open **Install application**,
**Git repository**, and enter this repository's URL. Pods reads `pods.yml`,
offers a hostname for the web interface when the host has the Pods proxy, and
can turn on **On demand** for it. It also sets up the hourly retrieve timer from
the `timers:` section of `pods.yml`, and shows it on the application's page with
**Run now**.

### By hand

The Quadlet files in `containers/systemd/spotweb` define the Spotweb and
MariaDB containers. [lpod](https://github.com/foxws/lpod) adds the socket that
starts Spotweb on demand, and the timer that runs the retrieve job:

```bash
podman quadlet install --application=spotweb containers/systemd/spotweb
lpod spotweb ondemand enable --port 8000 --app-port 8000
echo '{"timers": [{"name": "retrieve", "container": "spotweb-retrieve", "on_calendar": "hourly", "persistent": true, "randomized_delay_sec": "5min"}]}' \
    | lpod spotweb timers set --stdin --json
```

Without lpod, start it with `systemctl --user start spotweb` and publish its
port in a drop-in, such as `spotweb.container.d/ports.conf`:

```ini
[Container]
PublishPort=127.0.0.1:8000:8000
```

Then add the timer as `~/.config/systemd/user/spotweb-retrieve.timer`, and
enable it with `systemctl --user daemon-reload` and
`systemctl --user enable --now spotweb-retrieve.timer`:

```ini
[Timer]
Unit=spotweb-retrieve.service
OnCalendar=hourly
Persistent=true
RandomizedDelaySec=5min

[Install]
WantedBy=timers.target
```

On a server, also run `loginctl enable-linger` once, so the socket and timer
start at boot without logging in.

On first boot, the container seeds `config/dbsettings.inc.php` on the host from
the image's bundled default (already pointed at the included MariaDB
container). That file is bind-mounted into the container and symlinked to
`/app/dbsettings.inc.php`, so anything Spotweb itself writes there — such as
during install — persists automatically; no manual copying required.

Run the installer at <http://localhost:8000/install.php> to set up the
database schema and initial settings.

## Usage

After install, it should be available at <http://localhost:8000/>.

### Scale to zero

With on-demand on, nothing runs until the first request. A systemd socket
listens on port 8000; the first connection starts MariaDB and Spotweb, and the
request waits until both are ready. After 10 minutes without traffic, both
stop again. Change the port or the idle timeout on the application's page in
Pods, or with `lpod spotweb ondemand enable --port PORT --app-port 8000
--idle-timeout 60min`, and turn it off with `lpod spotweb ondemand disable`.

### Retrieving spots

`spotweb-retrieve.timer` runs `retrieve.php` every hour in a short-lived
container, starting MariaDB for it if needed. Run it by hand with **Run now** in
Pods, `lpod spotweb timers run retrieve --json` or
`systemctl --user start spotweb-retrieve`, and follow it with
`journalctl --user -u spotweb-retrieve -f`. Runs fail until the installer has
set up the database.

## Production

For production use, store database credentials in Podman secrets instead of
plain files or environment variables.
