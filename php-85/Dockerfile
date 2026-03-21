# ── Build PHP extensions ─────────────────────
FROM php:8.5-fpm-alpine AS builder

RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    libpng-dev libjpeg-turbo-dev gd-dev oniguruma-dev libxml2-dev \
    libzip-dev imagemagick-dev libwebp-dev freetype-dev libxslt-dev icu-dev \
    $PHPIZE_DEPS \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl xsl \
    && pecl install redis imagick \
    && docker-php-ext-enable redis imagick

# ── Production ───────────────────────────────
FROM php:8.5-fpm-alpine AS production

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

RUN apk update && apk upgrade --no-cache && apk add --no-cache \
    jq git curl zip unzip dcron imagemagick ffmpeg wget supervisor \
    jpegoptim optipng pngquant gifsicle libavif-apps libwebp-tools \
    libpng libjpeg-turbo gd oniguruma libxml2 libzip \
    imagemagick-libs libwebp freetype libxslt icu-libs ca-certificates

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY ./entrypoint.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh
ENTRYPOINT ["/var/www/entrypoint.sh"]

# ── Dev ──────────────────────────────────────
FROM production AS dev

RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS linux-headers \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps

COPY ./xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug-config.ini

COPY ./entrypoint.dev.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh
