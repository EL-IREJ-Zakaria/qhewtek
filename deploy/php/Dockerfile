FROM php:8.3-fpm-alpine

RUN docker-php-ext-install pdo_mysql

WORKDIR /var/www/backend

COPY backend/ /var/www/backend/
COPY deploy/php/entrypoint.sh /usr/local/bin/qhewtek-php-entrypoint

RUN chmod +x /usr/local/bin/qhewtek-php-entrypoint

ENTRYPOINT ["qhewtek-php-entrypoint"]
CMD ["php-fpm"]
