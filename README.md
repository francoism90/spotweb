# Spotweb

This a example of a Spotweb docker setup using Podman and FrankenPHP.

## Disclaimer

This setup is intended for locating abandonware — software (e.g. old games)
whose licenses have expired or are no longer maintained or enforced. I'm not
responsible for the content indexed or how this instance is used.

## Install

On first boot, the container seeds `config/dbsettings.inc.php` on the host from
the image's bundled default (already pointed at the included MariaDB
container). That file is bind-mounted into the container and symlinked to
`/app/dbsettings.inc.php`, so anything Spotweb itself writes there — such as
during install — persists automatically; no manual copying required.

Run the installer at <http://localhost:8000/install.php> to set up the
database schema and initial settings.

## Usage

After install, it should be available at <http://localhost:8000/>.

## Production

For production use, store database credentials in Podman secrets instead of
plain files or environment variables.
