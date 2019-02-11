FROM alpine:3.9

LABEL Maintainer="Filippo Bovo <f.bovo@hobiri.com>" \
      Description="Lightweight container with Nginx & PHP-FPM 7."

# Install packages
RUN apk --no-cache add curl supervisor nginx php7 php7-fpm
# Install PHP extensions
# RUN apk --no-cache add \
#     php7-amqp \
#     php7-apache2 \
#     php7-apcu \
#     php7-bcmath \
#     php7-bz2 \
#     php7-calendar \
#     php7-cgi \
#     php7-common \
#     php7-ctype \
#     php7-curl \
#     php7-dba \
#     php7-dev \
#     php7-doc \
#     php7-dom \
#     php7-embed \
#     php7-enchant \
#     php7-exif \
#     php7-fileinfo \
#     php7-fpm \
#     php7-ftp \
#     php7-gd \
#     php7-gettext \
#     php7-gmp \
#     php7-iconv \
#     php7-imagick \
#     php7-imap \
#     php7-intl \
#     php7-json \
#     php7-ldap \
#     php7-litespeed \
#     php7-mailparse \
#     php7-mbstring \
#     php7-mcrypt \
#     php7-memcached \
#     php7-mysqli \
#     php7-mysqlnd \
#     php7-odbc \
#     php7-opcache \
#     php7-openssl \
#     php7-pcntl \
#     php7-pdo \
#     php7-pdo_dblib \
#     php7-pdo_mysql \
#     php7-pdo_odbc \
#     php7-pdo_pgsql \
#     php7-pdo_sqlite \
#     php7-pear \
#     php7-pgsql \
#     php7-phar \
#     php7-phpdbg \
#     php7-posix \
#     php7-pspell \
#     php7-recode \
#     php7-redis \
#     php7-session \
#     php7-shmop \
#     php7-simplexml \
#     php7-snmp \
#     php7-soap \
#     php7-sockets \
#     php7-sqlite3 \
#     php7-sysvmsg \
#     php7-sysvsem \
#     php7-sysvshm \
#     php7-tidy \
#     php7-tokenizer \
#     php7-wddx \
#     php7-xdebug \
#     php7-xml \
#     php7-xmlreader \
#     php7-xmlrpc \
#     php7-xmlwriter \
#     php7-xsl \
#     php7-zip \
#     php7-zlib \
#     php7-zmq \

# Configure NginX
# COPY etc/nginx/ /etc/nginx/
RUN sed -i "s|user\s*nginx;|# user nobody;\npid /run/nginx.pid;|g" /etc/nginx/nginx.conf

# Configure PHP-FPM
# COPY etc/php7/ /etc/php7/

# Configure supervisord
COPY etc/supervisord.conf /etc/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
    chown -R nobody.nobody /var/lib/nginx && \
    chown -R nobody.nobody /var/tmp/nginx && \
    chown -R nobody.nobody /var/log/nginx

# Setup document root
# RUN mkdir -p /usrlocal/share/html
RUN mkdir -p /var/www/html

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
# COPY --chown=nobody html/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up & running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
