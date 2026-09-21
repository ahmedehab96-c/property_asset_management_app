# syntax=docker/dockerfile:1

# ---- 1. Build the React admin dashboard ----
FROM node:20-alpine AS frontend-build
WORKDIR /app
COPY admin-dashboard/package.json admin-dashboard/package-lock.json* ./admin-dashboard/
RUN cd admin-dashboard && npm ci
COPY admin-dashboard ./admin-dashboard
# vite.config.js outputs to ../backend/public/dashboard
RUN mkdir -p backend/public && cd admin-dashboard && npm run build

# ---- 2. Install PHP (Composer) dependencies ----
FROM composer:2 AS composer-build
WORKDIR /app
COPY backend/composer.json backend/composer.lock ./
RUN composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction
COPY backend ./
RUN composer dump-autoload --optimize --no-dev

# ---- 3. Runtime image ----
FROM php:8.3-apache AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
        libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libicu-dev \
        libpq-dev sqlite3 libsqlite3-dev unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        pdo_mysql pdo_pgsql pdo_sqlite mbstring exif pcntl bcmath gd intl zip opcache \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Laravel's public/ is the document root; the built React app already lives
# under public/dashboard (copied below) and is served as static files there.
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf \
    && sed -ri -e "s!/var/www/!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

COPY backend ./
COPY --from=composer-build /app/vendor ./vendor
COPY --from=frontend-build /app/backend/public/dashboard ./public/dashboard

RUN cp .env.example .env \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80

ENTRYPOINT ["entrypoint.sh"]
CMD ["apache2-foreground"]
