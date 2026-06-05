FROM php:8.5.7-apache

ARG VERSION="3.11.5"

RUN set -eux ; \
    apt-get update ; \
    apt-get -y upgrade ; \
    apt-get -y install --no-install-recommends \
        libpng-dev \
        libzip-dev \
    ; \
    rm -rf /var/lib/apt/lists/* ; \
    docker-php-ext-install \
        gd \
        pdo_mysql

RUN set -eux ; \
    curl -sfL "https://github.com/jreklund/php4dvd/archive/refs/tags/v${VERSION}.tar.gz" | tar zxvf - --strip-components=1 ; \
    chmod 770 cache compiled movies movies/covers ; \
    chown www-data:www-data cache compiled movies movies/covers ; \
    rm -rf install

COPY skin-foosh.css skin-foosh.min.css /var/www/html/tpl/default/css/skins/
COPY logo-foosh.png /var/www/html/tpl/default/images/

COPY baseurl.patch mysqltls.patch /usr/local/src
RUN set -eux ; \
    patch -p0 < /usr/local/src/baseurl.patch ; \
    patch -p0 < /usr/local/src/mysqltls.patch

COPY entrypoint.sh /usr/local/sbin
ENTRYPOINT ["/usr/local/sbin/entrypoint.sh"]
CMD ["apache2-foreground"]
