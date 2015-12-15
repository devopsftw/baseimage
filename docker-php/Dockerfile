FROM e96tech/baseimage
MAINTAINER Alex Salt <alex.salt@e96.ru>

# install packages
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    php5-cli php5-fpm php5-curl php5-json php5-mysqlnd php5-mcrypt \
    php-apc php5-gd php5-imagick php5-imap php5-memcache php5-xmlrpc \
    nginx \
    git

# sending flying fists to ubuntu maintainers -.-
RUN php5enmod mcrypt && php5enmod imap

ADD nginx.sh /etc/service/nginx/run
ADD php-fpm.sh /etc/service/php-fpm/run

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.0.0-alpha10

# configure php
ADD php/fpm/ /etc/php5/fpm/
ADD php/php-cli.ini /etc/php5/cli/php.ini
RUN mkdir /var/log/fpm && chown www-data:www-data /var/log/fpm

# configure nginx
ADD nginx/ /etc/nginx/

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
