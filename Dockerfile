# https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html
FROM webdevops/php-nginx:7.4
ARG DOMAIN

RUN echo "DOMAIN: $DOMAIN"

COPY . /var/www/mellivora/
COPY ./nginx_config/nginx /etc/nginx
RUN envsubst '$DOMAIN' < /etc/nginx/nginx.conf.template > /etc/nginx.conf

ENV WEB_DOCUMENT_ROOT /var/www/mellivora/
ENV WEB_DOCUMENT_INDEX index.php
ENV WEB_ALIAS_DOMAIN $DOMAIN
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/mellivora/
RUN composer install --no-dev --optimize-autoloader
