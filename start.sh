#!/usr/bin/env bash

# if the user wants to run compose install
if [[ $COMPOSER_INSTALL == true ]]; then
    # install laravel packages
    echo "install laravel packages"
    composer install --no-dev --no-progress --prefer-dist
fi

# if the user wants to run migrations
if [[ $PHP_ARTISAN_MIGRATE == true ]]; then
    echo "run migrations"
    php artisan migrate --force -vvv
    echo "run passport:keys"
    php artisan passport:keys --force
fi

# if the user wants to run migrations
if [[ $PHP_ARTISAN_DB_SEED == true ]]; then
    echo "run db:seed"
    php artisan db:seed --force --no-interaction
fi
echo "composer dump-autoload"
composer dump-autoload --no-dev --optimize

echo "fixing permission"
chmod 777 -R storage vendor

ls -la
# Starts FPM
echo "Starts FPM"
nohup /usr/sbin/php-fpm7 -y /etc/php7/php-fpm.conf -F -O 2>&1 &

# if this container should run as a cron
if [[ $PHP_ARTISAN_CRON == true ]]; then
    echo "php artisan schedule:run "
    crond -s /var/spool/cron/crontabs -b -L /var/log/cron/cron.log "$@" && tail -f /var/log/cron/cron.log
fi

# if this container should run as a worker
if [[ $PHP_ARTISAN_WORKER == true ]]; then
    echo "php artisan queue:work"
    php artisan queue:work
fi
# Starts nginx!
echo "Starts nginx!"
nginx
