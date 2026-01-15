#!/bin/bash

# usage: sh run-hub.sh <IMAGE_TAG> [REPO_NAME]
# example: sh run-hub.sh bc0e739... myuser/myapp

IMAGE_TAG=${1:-latest}
REPO_NAME=${2:-your_dockerhub_username/nodejs-ci-cd-demo}
FULL_IMAGE="${REPO_NAME}:${IMAGE_TAG}"

echo "Running image: $FULL_IMAGE"

# 1. Create network
docker network create my-network 2>/dev/null || true

# 2. Start Postgres (Always restart to ensure clean state)
if [ "$(docker ps -aq -f name=postgres-container-name)" ]; then
    docker rm -f postgres-container-name
fi

# Cleanup existing app container to avoid port conflicts
if [ "$(docker ps -aq -f name=nodejs-app-container)" ]; then
    docker rm -f nodejs-app-container
fi

echo "Start new Postgres container..."
docker run -d --name postgres-container-name \
  --network my-network \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=mydb \
  postgres:15-alpine
  
echo "Waiting for Postgres to start..."
sleep 10

# Debug: Check if migration file exists
echo "Current directory: $PWD"
ls -l db/migration/V1__Create_items_table.sql

# 3. Run Flyway Migration
echo "Running database migrations..."
# MSYS_NO_PATHCONV=1 prevents Git Bash from mangling the path /flyway/sql
MSYS_NO_PATHCONV=1 docker run --rm \
  --network my-network \
  -v "$PWD/db/migration:/flyway/sql" \
  flyway/flyway \
  -url=jdbc:postgresql://postgres-container-name:5432/mydb \
  -user=myuser \
  -password=mypassword \
  -connectRetries=60 \
  -baselineOnMigrate=true \
  migrate

# 4. Run the Application
echo "Starting application from Hub..."

DOCKER_FLAGS="--rm"
if [ "$DETACHED" = "true" ]; then
    DOCKER_FLAGS="-d --rm"
    echo "Running in detached mode..."
fi

docker run $DOCKER_FLAGS -p 3000:3000 \
  --name nodejs-app-container \
  --network my-network \
  -e POSTGRES_HOST=postgres-container-name \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_DB=mydb \
  $FULL_IMAGE
