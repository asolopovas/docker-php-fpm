FROM surnet/alpine-wkhtmltopdf:3.10-0.12.6-small as wkhtmltopdf
FROM php:7.4.4-fpm-alpine3.11

# Copy wkhtmltopdf files from docker-wkhtmltopdf image
COPY --from=wkhtmltopdf /bin/wkhtmltopdf /bin/wkhtmltopdf
COPY --from=wkhtmltopdf /bin/libwkhtmltox* /bin/

# Install workspace dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-dev \
    msttcorefonts-installer

# Install production dependencies
RUN apk add --no-cache \
    shadow \
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
    libstdc++ \
    libx11 \
    libxrender \
    libxext \
    libssl1.1 \
    make \
    oniguruma-dev \
    openssh-client \
    postgresql-libs \
		redis \
    ca-certificates \
    fontconfig \
    freetype \
    ttf-dejavu \
    ttf-droid \
    ttf-freefont \
    ttf-liberation \
    ttf-ubuntu-font-family \
    zlib-dev

# Install microsoft fonts
RUN update-ms-fonts; \
    fc-cache -f

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
RUN apk del -f .build-deps; \
    rm -rf /tmp/*

# www-data group/userid 1000
RUN  set -ex; usermod -u 1000 www-data; groupmod -g 1000 www-data; \
     chown -R 1000:1000 /var/www /home/www-data;

RUN apk add --no-cache bash zsh neovim mysql-client rsync su-exec sudo libstdc++ zsh-vcs
