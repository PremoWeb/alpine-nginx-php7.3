FROM alpine:3.12

LABEL org.opencontainers.image.source = "https://github.com/PremoWeb/alpine-nginx-php7.3"

# Install packages and remove default server definition
RUN apk --no-cache add php7 php7-fpm php7-opcache php-pdo php7-mysqli php-sqlite3 php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-ctype php7-session  \
    php7-mbstring php7-gd nginx supervisor curl \
    php7-simplexml php7-pdo_sqlite php7-pdo_mysql php7-redis php7-ldap php7-iconv php7-xmlrpc geoip php7-pcntl git composer && \
    rm /etc/nginx/conf.d/default.conf

# Configure nginx
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY php7/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY php7/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY nginx/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

USER nobody

WORKDIR /var/www/html

EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]