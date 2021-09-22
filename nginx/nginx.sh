#!/bin/sh

set -e

if [ -z "$DOMAIN" ]; then
  echo "DOMAIN environment variable is not set"
  exit 1;
fi

envsubst '$DOMAIN' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

if [ ! -f "/etc/nginx/ssl/dummy/$DOMAIN/fullchain.pem" ]; then
echo "Generating dummy ceritificate for $DOMAIN"
mkdir -p "/etc/nginx/ssl/dummy/$DOMAIN"
printf "[dn]\nCN=${DOMAIN}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:${DOMAIN}, DNS:www.${DOMAIN}\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > openssl.cnf
openssl req -x509 -out "/etc/nginx/ssl/dummy/$DOMAIN/fullchain.pem" -keyout "/etc/nginx/ssl/dummy/$DOMAIN/privkey.pem" \
  -newkey rsa:2048 -nodes -sha256 \
  -subj "/CN=${DOMAIN}" -extensions EXT -config openssl.cnf
rm -f openssl.cnf
fi

if [ ! -f /etc/nginx/ssl/ssl-dhparams.pem ]; then
  openssl dhparam -dsaparam -out /etc/nginx/ssl/ssl-dhparams.pem 2048
fi

use_lets_encrypt_certificates() {
  echo "Switching Nginx to use Let's Encrypt certificate for $1"
  sed -i "s|/etc/nginx/ssl/dummy/$1|/etc/letsencrypt/live/$1|g" /etc/nginx/conf.d/default.conf
}

reload_nginx() {
  echo "Reloading Nginx configuration"
  nginx -s reload
}

wait_for_lets_encrypt() {
  until [ -d "/etc/letsencrypt/live/$1" ]; do
    echo "Waiting for Let's Encrypt certificates for $1"
    sleep 5s & wait ${!}
  done
  use_lets_encrypt_certificates "$1"
  reload_nginx
}

if [ ! -d "/etc/letsencrypt/live/$1" ]; then
wait_for_lets_encrypt "$DOMAIN" &
else
use_lets_encrypt_certificates "$DOMAIN"
fi

exec nginx -g "daemon off;"
# echo "Certificates acquired!"
