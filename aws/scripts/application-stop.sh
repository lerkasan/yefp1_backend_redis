#!/bin/bash
set -xe

APP_DIR=/home/ubuntu/backend_redis

cd "$APP_DIR" || exit
docker compose down
