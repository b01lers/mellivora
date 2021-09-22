#!/bin/bash

envsubst '$DOMAIN' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
