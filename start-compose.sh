#!/usr/bin/env bash

# Needed to make docker compose secrets work
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

docker compose build --no-cache
docker compose up
