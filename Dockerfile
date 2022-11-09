FROM php:8.1-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    cron

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mysqli mbstring exif pcntl bcmath gd zip soap intl

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install redis extension for php
RUN pecl install redis && docker-php-ext-enable redis

# Set working directory
WORKDIR /var/www

# Install depedencies, set .env file, clear all caches and start fpm
CMD cp .env.example .env && composer install && php artisan key:generate && php artisan storage:link && php artisan migrate --force && php-fpm