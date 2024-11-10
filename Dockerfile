# Dockerfile
FROM php:8.2-apache

# Enable detailed logging
RUN set -ex

# Update package list and install dependencies
RUN apt-get update \
    && apt-get install -y \
        zip \
        unzip \
        git \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libonig-dev \
        libzip-dev \
        libmcrypt-dev \
        libsodium-dev

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql sodium

# Clean up
RUN apt-get clean

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Composer version
RUN composer --version

# Copy custom php.ini
COPY php.ini /usr/local/etc/php/php.ini

# Set working directory
WORKDIR /var/www/html

# Install Drupal using Composer
RUN composer create-project drupal/recommended-project .

# Run Composer install
RUN composer install

# Set permissions for Drupal
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80