#!/bin/bash

envsubst '$DOMAIN' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
chmod -R 777 /var/www/mellivora/writable/
