FROM php:7.4-fpm-alpine

# Install workspace dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-dev

# Install production dependencies
RUN apk add --no-cache \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    imagemagick \
    libc-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    make \
    oniguruma-dev \
    openssh-client \
    postgresql-libs \
		redis \
    zlib-dev 

# Install PECL and PEAR extensions
RUN pecl install \
    imagick \
    redis \
    xdebug

# Enable PECL and PEAR extensions
RUN docker-php-ext-enable \
    imagick \
    redis

# Configure php extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install php extensions
RUN docker-php-ext-install \
    bcmath \
    calendar \
    curl \
    exif \
    gd \
    iconv \
    mbstring \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    tokenizer \
    xml \
    zip

# fix work iconv library with alphine
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Install composer
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Install PHP_CodeSniffer
RUN composer global require "squizlabs/php_codesniffer=*" --no-cache
RUN chown -R www-data:www-data /composer

# Enable Opcache
COPY opcache.ini $PHP_INI_DIR/conf.d/opcache.ini

# Cleanup workspace dependencies
RUN apk del -f .build-deps

# Assign www-data ownership
RUN set -ex; \
  chown -R www-data:www-data /var/www


# Install Oh-My-Zsh
RUN git clone "https://github.com/ohmyzsh/ohmyzsh.git" "/usr/share/ohmyzsh"


RUN apk add --no-cache \ 
		bash \
		zsh \
		neovim \
    mysql-client \
    rsync \
    su-exec

