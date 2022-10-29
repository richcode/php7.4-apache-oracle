FROM php:7.4-apache

RUN apt-get update \
    && apt-get install -y unzip libaio-dev libmcrypt-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    && apt-get clean -y

# Install gd and zip
RUN docker-php-ext-install zip && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j "$(nproc)" gd

# PHP composer
RUN curl -sS https://getcomposer.org/installer | php --  --install-dir=/usr/bin --filename=composer

ADD https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip /tmp/
ADD https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-sdk-linux.x64-21.1.0.0.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-*.zip -d /usr/local/ \
    && unzip /tmp/instantclient-sdk-linux.x64-*.zip -d /usr/local/ 

RUN ln -s /usr/local/instantclient_*_1 /usr/local/instantclient

RUN docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient \
    && docker-php-ext-install oci8 \
    && echo /usr/local/instantclient/ > /etc/ld.so.conf.d/oracle-insantclient.conf \
    && ldconfig