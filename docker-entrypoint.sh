#!/bin/sh
set -eou pipefail

# echo "Collecting static files"
# python manage.py collectstatic --noinput

CPU_CORES=$(grep ^cpu\\scores /proc/cpuinfo | uniq | awk '{print $4}')
WORKERS=$(($CPU_CORES * 2 + 1))

echo "Starting server"
gunicorn backend_redis.wsgi:application --workers "$WORKERS" --bind 0.0.0.0:9000