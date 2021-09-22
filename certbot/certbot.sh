#!/bin/bash

set -e

trap exit INT TERM

if [ -z "$DOMAIN" ]; then
  echo "DOMAIN environment variable is not set"
  exit 1;
fi

until nc -z nginx 80; do
  echo "Waiting for nginx to start..."
  sleep 5s & wait ${!}
done

if [ "$CERTBOT_TEST_CERT" != "0" ]; then
  test_cert_arg="--test-cert"
fi

if [ -d "/etc/letsencrypt/live/$DOMAIN" ]; then
echo "Let's Encrypt certificate for $DOMAIN already exists"
fi

echo "Obtaining the certificate for $DOMAIN"

if [ -z "$EMAIL" ]; then
email_arg="--register-unsafely-without-email"
else
email_arg="--email $EMAIL"
fi

mkdir -p "/var/www/certbot/$DOMAIN"

certbot certonly \
--webroot \
-w "/var/www/certbot/$DOMAIN" -d "$DOMAIN" \
$test_cert_arg \
$email_arg \
--rsa-key-size "${CERTBOT_RSA_KEY_SIZE:-4096}" \
--agree-tos \
--noninteractive || true
