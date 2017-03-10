from php:7.1.2-fpm-alpine

ENV PHPREDIS_VERSION 3.0.0

RUN apk add --update freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev \
		cyrus-sasl-dev libmemcached-dev zlib-dev \
		libmcrypt-dev curl-dev libxml2-dev \
		autoconf g++ imagemagick-dev libtool make \
	  && docker-php-ext-configure gd \
		--with-freetype-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-webp-dir=/usr/include

RUN docker-php-ext-install gd

RUN mkdir -p /usr/src/php/ext/redis \
		&& curl -L https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
		&& echo 'redis' >> /usr/src/php-available-exts \
		&& docker-php-ext-install redis

RUN curl -sSL -A "Docker" -D - -o /tmp/ext-memcached.tgz https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz \
		&& tar zxpf /tmp/ext-memcached.tgz -C /tmp \
		&& cd /tmp/php-memcached-php7 \
		&& phpize \
		&& ./configure \
			--disable-memcached-sasl \
			--with-zlib-dir=/usr \
		&& make \
		&& make install

RUN docker-php-ext-enable memcached
RUN docker-php-ext-install curl
RUN docker-php-ext-install exif
RUN docker-php-ext-install ftp
RUN docker-php-ext-install iconv
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install opcache
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install simplexml
RUN docker-php-ext-install xml
RUN docker-php-ext-install zip
RUN pecl update-channels \
    && pecl install imagick \
    && docker-php-ext-enable imagick

RUN apk del autoconf g++ libtool make \
    && rm -rf /tmp/* /var/cache/apk/*

COPY php-run.sh /usr/local/bin/php-run.sh
RUN chmod +x /usr/local/bin/php-run.sh
CMD /usr/local/bin/php-run.sh
