###
# Rafael Bernardo
#
# Repository:    PHP
# Image:         CLI/Base
# Version:       7.3.x
# Strategy:      PHP From PHP-Alpine Repository
# Base distro:   Alpine 3.10
#
FROM alpine:3.10

# Variables
ENV TERM=xterm-256color \
    COLORTERM=truecolor \
    COMPOSER_PROCESS_TIMEOUT=1200 \
    COMPOSER_INSTALL=false \
    LOG_CHANNEL=stderr \
    TINI_VERSION=v0.18.0


# Install PHP , Nginx Common Tools, Composer and then cleanup
RUN echo "---> Enabling PHP-Alpine" && \
    apk add --update --no-cache \
    bash \
    bash-completion \
    openrc \
    curl \
    fontconfig \
    libxrender \
    libxext \
    vim \
    git \
    unzip \
    wget \
    sudo \
    nginx \
    php7 \
    php7-apcu \
    php7-bcmath \
    php7-bz2 \
    php7-ctype \
    php7-curl \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-gd \
    php7-gmp \
    php7-iconv \
    php7-imagick \
    php7-imap \
    php7-intl \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-mysqlnd \
    php7-opcache \
    php7-openssl \
    php7-pdo_mysql \
    php7-pdo_pgsql \
    php7-pdo_sqlite \
    php7-pgsql \
    php7-phar \
    php7-posix     \
    php7-redis \
    php7-simplexml \
    php7-soap \
    php7-sqlite3 \
    php7-tokenizer \
    php7-xdebug \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-xsl \
    php7-zip \
    php7-zlib \
    php7-phpdbg && \
    echo "---> Installing Composer" && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir -p /var/www/app && \
    wget -O /tini https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini-static && \
    chmod +x /tini && \
    echo "--> FFMPEG" && \
    ffmpeg && \
    echo "---> Configuring PHP" && \
    sed -i "/listen = .*/c\listen = [::]:9000" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;access.log = .*/c\access.log = /proc/self/fd/2" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;clear_env = .*/c\clear_env = no" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/;catch_workers_output = .*/c\catch_workers_output = yes" /etc/php7/php-fpm.d/www.conf && \
    sed -i "/pid = .*/c\;pid = /run/php/php7.1-fpm.pid" /etc/php7/php-fpm.conf && \
    sed -i "/;daemonize = .*/c\daemonize = yes" /etc/php7/php-fpm.conf && \
    sed -i "/error_log = .*/c\error_log = /proc/self/fd/2" /etc/php7/php-fpm.conf && \
    sed -i "/post_max_size = .*/c\post_max_size = 1000M" /etc/php7/php.ini && \
    sed -i "/memory_limit = .*/c\memory_limit = 4096M" /etc/php7/php.ini && \
    sed -i "/upload_max_filesize = .*/c\upload_max_filesize = 1000M" /etc/php7/php.ini && \
    mkdir /var/run/nginx && \
    echo "--> Cleanup &&" \
    rm -r /var/cache/apk && \
    rm -r /usr/share/man 
# Nginx conf
COPY nginx.conf /etc/nginx/nginx.conf

# # Add the ENTRYPOINT script
COPY start.sh /scripts/start.sh
RUN echo "--> Fixing permissions and PID for nginx" && \
    chmod +x /scripts/*.sh

# Application directory
WORKDIR /var/www/app
VOLUME [ "/root/.composer" ]
# PATH with new binaries
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Define the entry point that tries to enable newrelic
CMD ["/tini", "--", "/scripts/start.sh"]

EXPOSE 80
