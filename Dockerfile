FROM php:7.0-fpm-alpine

ARG USER="laravel"

ENV PHP_USER ${USER}
ENV PHP_GROUP ${USER}
ENV PHP_PORT 9000
ENV PHP_PM dynamic
ENV PHP_PM_MAX_CHILDREN 10
ENV PHP_PM_START_SERVERS 4
ENV PHP_PM_MIN_SPARE_SERVERS 2
ENV PHP_PM_MAX_SPARE_SERVERS 6
ENV COMPOSER_HOME /composer
ENV PATH ./vendor/bin:/composer/vendor/bin:$PATH
ENV COMPOSER_ALLOW_SUPERUSER 1

RUN set -x \
  && addgroup -g 1000 -S ${USER} \
  && adduser -u 1000 -D -S -G ${USER} ${USER}

# Install dev dependencies
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
    bash \
    curl \
    g++ \
    gcc \
    git \
    imagemagick \
    libc-dev \
    libpng-dev \
    freetype-dev \
    libwebp-dev \
    libjpeg-turbo-dev \
    make \
    mysql-client \
    nodejs \
    nodejs-npm \
    yarn \
    openssh-client \
    postgresql-libs \
    rsync \
    zlib-dev \
    libzip-dev

# Install PECL and PEAR extensions
RUN pecl install \
    imagick

# Install and enable php extensions
RUN docker-php-ext-enable imagick \
    && docker-php-ext-configure zip --with-libzip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/  --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install \
    curl \
    iconv \
    mbstring \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    tokenizer \
    xml \
    gd \
    zip \
    bcmath

COPY container /

RUN curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer \
    && composer global require "squizlabs/php_codesniffer=*"

RUN apk del -f .build-deps

USER ${USER}

WORKDIR /srv/laravel
