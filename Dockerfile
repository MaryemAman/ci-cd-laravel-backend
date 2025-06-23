# Use official PHP image with FPM (adjust version if needed)
# FROM php:8.1-fpm
FROM php:8.2-fpm

# Install system dependencies and PHP extensions needed for Laravel
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    && docker-php-ext-install pdo_mysql zip mbstring exif pcntl bcmath gd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer globally (copy from official composer image)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy only composer.json and composer.lock first
COPY composer.json composer.lock ./

# Run composer install (no dev dependencies, optimized) with verbose output
# RUN composer install --no-dev --optimize-autoloader -vvv
# RUN composer install --no-dev --optimize-autoloader || (cat /root/.composer/composer.log && false)

# Now copy the rest of the application code
COPY . .

# Fix permissions for storage and cache folders
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM server
# CMD ["php-fpm"]
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=9000"]

