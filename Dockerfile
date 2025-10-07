FROM php:8.2-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    openssl \
    mariadb-client \
    && docker-php-ext-install mysqli pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# Copy app and nginx config
COPY www /var/www/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Generate SSL cert for HTTPS
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -subj "/CN=mywebsite.local/O=MyWebsite/C=ID" \
    -keyout /etc/nginx/ssl/mywebsite.local.key \
    -out /etc/nginx/ssl/mywebsite.local.crt

# Nginx log directories
RUN mkdir -p /var/log/nginx /run/php && \
    chown -R www-data:www-data /var/www/html

EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
