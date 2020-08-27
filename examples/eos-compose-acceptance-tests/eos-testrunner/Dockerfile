FROM eos/base

ENV CGO_ENABLED=1
ENV GOOS=linux
RUN yum -y install epel-release yum-utils
RUN yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
RUN yum-config-manager --enable remi-php73
RUN rpm --rebuilddb && yum -y install \
    wget \
    time \
    make \
    git \
    php-cli \
    php-pdo \
    php-zip \
    php-sabre-dav \
    php-curl \
    php-dom \
    php-gd \
    php-json \
    php-mysql \
    php-intl \
    php-imagick \
    php-zip \
    php-xdebug \
    php-pgsql \
    php-sqlite3 \
    php-ldap \
    php-memcached \
    php-redis \
    php-apcu \
    php-ast \
    unzip

RUN mkdir -p /usr/local/bin
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN git clone -b master --depth=1 https://github.com/owncloud/testing.git /testing
RUN git clone -b master --depth=1 https://github.com/owncloud/core.git /testrunner
RUN cd /testrunner && make vendor-bin/behat/vendor
COPY entrypoint /entrypoint
