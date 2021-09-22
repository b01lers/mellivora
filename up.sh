#!/bin/bash

set -a

. config.env

set +a

docker-compose up --build --force-recreate
