CMD rm bootstrap/cache/*.php
cp .env.example .env
COMPOSER=composer-dev.json composer update --no-scripts
service supervisor start
service cron start
php artisan key:generate
php artisan storage:link
php artisan config:clear
php artisan route:clear
php artisan view:clear
php-fpm &
tail -f /dev/null
