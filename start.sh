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
    echo "run storage:link"
    php artisan storage:link -vvv

    echo "run passport:keys"
    php artisan passport:keys

    # run only on first deploy
    # echo "run passport:install"
    # php artisan passport:install --force
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
    #crond -s /var/spool/cron/crontabs -b -L /var/www/app/cronlog/cron.log "$@" && tail -f /var/www/app/cronlog/cron.log
    mkdir -p /var/www/app/cronlog/ && mkdir -m 0644 -p /var/www/app/cronlog/ && touch /var/www/app/cronlog/cron.log && mkdir -m 0644 -p /etc/cron.d && \
    echo -e "* * * * * sh /var/www/app/cronjob.sh" >> /var/www/app/cronjob.txt && \
    crontab /var/www/app/cronjob.txt && \
    echo -e "* * * * * php artisan schedule:run" >> /var/www/app/cronjob2.txt && \
    crontab /var/www/app/cronjob2.txt && \
    echo -e "* * * * * /var/www/app/cronjob.sh --verbose >> /var/www/app/cronlog/cron.log" && \
    chmod -R 0644 /var/www/app/cronlog
fi

# if this container should run as a worker
if [[ $PHP_ARTISAN_WORKER == true ]]; then
    echo "php artisan queue:work"
    php artisan queue:work
fi
# Starts nginx!
echo "Starts nginx!"
nginx
