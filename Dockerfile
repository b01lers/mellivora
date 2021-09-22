# https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html
FROM webdevops/php-nginx:7.4
ARG DOMAIN
ENV DOMAIN $DOMAIN

RUN echo "DOMAIN: $DOMAIN"
RUN apt-install gettext-base

COPY . /var/www/mellivora/
COPY ./nginx_config/nginx /etc/nginx
COPY ./nginx_config/99-subst.sh /opt/docker/provision/entrypoint.d/99-subst.sh

ENV WEB_DOCUMENT_ROOT /var/www/mellivora/
ENV WEB_DOCUMENT_INDEX index.php
ENV WEB_ALIAS_DOMAIN $DOMAIN
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/mellivora/
RUN composer install --no-dev --optimize-autoloader
