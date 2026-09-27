# Spotweb

This a example of a Spotweb docker setup using Podman and FrankenPHP.

## Disclaimer

This setup is intended for locating abandonware — software (e.g. old games)
whose licenses have expired or are no longer maintained or enforced. I'm not
responsible for the content indexed or how this instance is used.

## Install

The Quadlet files in `containers/systemd/spotweb` define the Spotweb and
MariaDB containers. The units in `containers/systemd/user` start them on
demand and run the hourly retrieve job; Quadlet can't generate sockets or
timers, so they're plain systemd units.

```bash
mkdir -p ~/.config/containers/systemd ~/.config/systemd/user
cp -r containers/systemd/spotweb ~/.config/containers/systemd/
cp containers/systemd/user/* ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now spotweb-ondemand.socket spotweb-retrieve.timer
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

Nothing runs until the first request. A systemd socket listens on port 8000;
the first connection starts MariaDB and Spotweb, and the request waits until
both are ready. After 10 minutes without traffic, both stop again. To change
that, edit `--exit-idle-time=` in `spotweb-ondemand.service`.

- `systemctl --user start spotweb` doesn't keep Spotweb running: nothing needs
  it, so systemd stops it again. Open it in the browser instead.
- Running another app that uses ports 8000 or 18000 on the same host? Change
  `ListenStream=` in `spotweb-ondemand.socket`, and the `PublishPort=` in
  `spotweb.container` together with the proxy's target in
  `spotweb-ondemand.service`.

### Retrieving spots

`spotweb-retrieve.timer` runs `retrieve.php` every hour in a short-lived
container, starting MariaDB for it if needed. Run it by hand with
`systemctl --user start spotweb-retrieve`, and follow it with
`journalctl --user -u spotweb-retrieve -f`. Runs fail until the installer has
set up the database.

## Production

For production use, store database credentials in Podman secrets instead of
plain files or environment variables.
