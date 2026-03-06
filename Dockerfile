FROM php:8.4-fpm-bookworm AS builder

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    libpng-dev libjpeg-dev libgd-dev libonig-dev libxml2-dev \
    libzip-dev libmagickwand-dev libwebp-dev libxslt-dev \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl xsl \
    && pecl install redis imagick \
    && docker-php-ext-enable redis imagick

FROM php:8.4-fpm-bookworm

# Copy compiled extensions from builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Only runtime dependencies — no -dev packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    jq git curl zip unzip cron imagemagick ffmpeg wget supervisor \
    jpegoptim optipng pngquant gifsicle libavif-bin webp pdftk-java \
    libpng16-16 libjpeg62-turbo libgd3 libonig5 libxml2 libzip4 \
    libmagickwand-6.q16-6 libwebp7 libxslt1.1 ca-certificates \
    && apt-get remove --purge -y \
        linux-libc-dev \
        libc6-dev \
        gcc \
        g++ \
        cpp \
        dpkg-dev \
        make \
    && apt-get autoremove -y \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www
COPY ./entrypoint.sh /var/www/entrypoint.sh
RUN chmod +x /var/www/entrypoint.sh
ENTRYPOINT ["/var/www/entrypoint.sh"]
