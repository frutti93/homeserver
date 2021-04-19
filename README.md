![GitHub Workflow Status](https://img.shields.io/github/workflow/status/frutti93/homeserver/build%20latest) ![GitHub Workflow Status](https://img.shields.io/github/workflow/status/frutti93/homeserver/build%20tagged) ![GitHub last commit](https://img.shields.io/github/last-commit/frutti93/homeserver)

# nextcloud-pihole-homeserver
Setup of my homeserver, running on my Raspberry Pi 4 with Arch Linux ARM (64bit). 

## Running the base
The basic setup containing reverse proxy, dynamic DNS updater and watchtower is included in `docker-compose.yml`.
This is meant to be run in combination with the other compose files.

To run this create:
* **./data/conf/dyndns/config.json**: Containing the information for your dynamic DNS, for more information see here: [Original repository](https://github.com/qdm12/ddns-updater)
* **./data/conf/traefic/acme.json**: This file will contain your certificates. Leave empty and run `chmod 600 acme.json` in the traefic directory to set the right permissions.

## Adding Containers
The other compose files can be run individually, except for `docker-compose.restore.yml`. All environment variables should be set using the `.env` file.

### `docker-compose.backup.yml` - Borgbackup with borgmatic
I use this to regularly backup my nextcloud instance both locally and in the cloud using rclone.
However it can be used to basically backup anthing you mount into it.
To use this container create the two files:
* **./data/conf/borgmatic/config.yaml**: Borgmatic config file to configure your backup jobs.
* **./data/conf/borgmatic/crontab.txt**: Cron config that will be used inside the container.

For more information see here: [docker-borgmatic](https://github.com/frutti93/docker-borgmatic). \
DISCLAIMER: This is also my repository.

### `docker-compose.nextcloud.yml` - Nextcloud
This runs a complete nextcloud server, with MariaDB and Redis behind the reverse proxy. 
The default setup uses a preconfigured image by be, which contains:
* Activated cronjob
* Possibility to preinstall apps, the included compose installs calendar, tasks, previewgenerator, keeweb`
* Preview generator will be run once a day to auto generate image previews
* *will be updated...*

If you dont want this, just use the regular nextcloud images.

### `docker-compose.pihole.yml` - Pihole
For network wide ad blocking. Does not need a separate config file, everything is set using the `.env` file.

