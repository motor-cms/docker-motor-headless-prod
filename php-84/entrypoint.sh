CMD rm bootstrap/cache/*.php
cp .env.example .env
composer install --no-scripts
service supervisor start
service cron start
php artisan key:generate
php artisan storage:link
php artisan optimize
php-fpm &
tail -f /dev/null
