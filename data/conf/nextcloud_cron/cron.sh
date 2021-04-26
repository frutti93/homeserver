#!/bin/sh
set -eu

run_as() {
    if [ "$(id -u)" = 0 ]; then
        su -p www-data -s /bin/sh -c "$1"
    else
        sh -c "$1"
    fi
}

install_custom_apps() {
  # https://stackoverflow.com/a/39568613/6334421
  # https://docs.nextcloud.com/server/19/admin_manual/configuration_server/>

  set +u
  set -- $CUSTOM_APPS  # don't quote variable here
  while [ -n "$1" ]; do
    run_as "php /var/www/html/occ app:install $1" || echo "<< WARNING >>"
    run_as "php /var/www/html/occ app:enable $1" || echo "<< WARNING >>"
    shift
  done
  set -u
}

install_custom_apps

echo 'Set proxy stuff'
run_as 'php occ config:system:set overwriteprotocol --value="https"'

echo 'Configuring preview generator...'
run_as 'php /var/www/html/occ config:app:set previewgenerator squareSizes --value="32 256"'
run_as 'php /var/www/html/occ config:app:set previewgenerator widthSizes  --value="256 384"'
run_as 'php /var/www/html/occ config:app:set previewgenerator heightSizes --value=256'
run_as 'php /var/www/html/occ config:system:set preview_max_x --value 2048'
run_as 'php /var/www/html/occ config:system:set preview_max_y --value 2048'
run_as 'php /var/www/html/occ config:system:set jpeg_quality --value 60'
run_as 'php /var/www/html/occ config:app:set preview jpeg_quality --value=60'

echo 'Creating cronjob...'
echo '* 1 * * * php occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data

exec busybox crond -f -l 0 -L /dev/stdout