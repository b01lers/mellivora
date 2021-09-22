# https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html
FROM webdevops/php-nginx:7.4

COPY ./htdocs /app/htdocs
COPY ./include /app/include
COPY ./writable /app/writable

COPY ./composer.json /app/composer.json
COPY ./composer.lock /app/composer.lock

COPY ./letsencrypt-docker-compose/nginx_ssl/dummy/${DOMAIN}/fullchain.pem /opt/docker/etc/nginx/ssl/server.crt
COPY ./letsencrypt-docker-compose/nginx_ssl/dummy/${DOMAIN}/privkey.pem /opt/docker/etc/nginx/ssl/server.key

ENV WEB_DOCUMENT_ROOT /app/htdocs
ENV WEB_DOCUMENT_INDEX index.php
ENV WEB_ALIAS_DOMAIN ${DOMAIN}
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /app 
RUN composer install --no-dev --optimize-autoloader
