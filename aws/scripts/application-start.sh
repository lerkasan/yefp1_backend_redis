#!/bin/bash
set -xe

APPLICATION_NAME="yefp1-backend-redis"
DEPLOYMENT_GROUP_NAME="stage-backend-redis"
APP_DIR=/home/ubuntu/backend_redis

CORS_ALLOWED_ORIGINS="http://localhost"
DEBUG=False

REDIS_PORT=6379
REDIS_DB=5

AWS_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
export AWS_REGION="${AWS_REGION:-us-east-1}"

AWS_ACCOUNT_ID=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .accountId)

DEPLOYMENT_ID=$(aws deploy list-deployments --application-name "$APPLICATION_NAME" --deployment-group-name "$DEPLOYMENT_GROUP_NAME" --region "$AWS_REGION" --include-only-statuses "InProgress" --query "deployments[0]" --output text --no-paginate)

COMMIT_SHA=$(aws deploy get-deployment --deployment-id "$DEPLOYMENT_ID" --query "deploymentInfo.revision.gitHubLocation.commitId" --output text)

BACKEND_REDIS_TAG="${COMMIT_SHA:-latest}"

REDIS_HOST=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_redis_host" --with-decryption --query Parameter.Value --output text)
REDIS_DB=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_redis_db" --with-decryption --query Parameter.Value --output text)
REDIS_PASSWORD=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_redis_password" --with-decryption --query Parameter.Value --output text)
SECRET_KEY=$(aws ssm get-parameter --region "$AWS_REGION" --name "${APPLICATION_NAME}_cache_secret_key" --with-decryption --query Parameter.Value --output text)

export REDIS_HOST="$REDIS_HOST"
export REDIS_PORT="$REDIS_PORT"
export REDIS_DB="$REDIS_DB"
export REDIS_PASSWORD="$REDIS_PASSWORD"

export SECRET_KEY="$SECRET_KEY"
export CORS_ALLOWED_ORIGINS="$CORS_ALLOWED_ORIGINS"
export DEBUG="$DEBUG"

export BACKEND_REDIS_TAG="${BACKEND_REDIS_TAG:-latest}"
export AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

cd "$APP_DIR" || exit
docker compose up -d