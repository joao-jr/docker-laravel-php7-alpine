#!/usr/bin/env bash

# if the user wants to run compose install
if [[ $COMPOSER_INSTALL == true ]]; then
    # install laravel packages
    composer install --prefer-dist --no-dev
fi

# if the user wants to run migrations
if [[ $PHP_ARTISAN_MIGRATE == true ]]; then
    php artisan migrate
fi
echo "composer dump-autoload"
composer dump-autoload --no-dev --optimize

echo "fixing permission"
chmod 777 -R storage vendor

ls -la
# Starts FPM
nohup /usr/sbin/php-fpm7 -y /etc/php7/php-fpm.conf -F -O 2>&1 &

# if this container should run as a worker
if [[ $PHP_ARTISAN_WORKER == true ]]; then
    echo "php artisan queue:work"
    php artisan queue:work
fi
# Starts nginx!
nginx
