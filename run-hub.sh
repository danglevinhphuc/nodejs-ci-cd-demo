#!/bin/bash

# usage: sh run-hub.sh <IMAGE_TAG> [REPO_NAME]
# example: sh run-hub.sh bc0e739... myuser/myapp

IMAGE_TAG=${1:-latest}
REPO_NAME=${2:-your_dockerhub_username/mono-repo}
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
ls -l backend/db/migration/V1__Create_items_table.sql

# 3. Run Flyway Migration
echo "Building temporary migration image..."
# Create a temp Dockerfile to bake migrations in. 
# This avoids volume mounting issues with Docker-out-of-Docker where host paths don't match container paths.
cat <<EOF > Dockerfile.flyway
FROM flyway/flyway
COPY backend/db/migration /flyway/sql
EOF

docker build -t temp-flyway-migration -f Dockerfile.flyway .

echo "Running database migrations..."
docker run --rm \
  --network my-network \
  temp-flyway-migration \
  -url=jdbc:postgresql://postgres-container-name:5432/mydb \
  -user=myuser \
  -password=mypassword \
  -connectRetries=60 \
  -baselineOnMigrate=true \
  migrate

# 5. Run the Backend Application
echo "Starting Backend from Hub..."
BACKEND_IMAGE="${REPO_NAME}:backend-${IMAGE_TAG}"
FRONTEND_IMAGE="${REPO_NAME}:frontend-${IMAGE_TAG}"

DOCKER_FLAGS="--rm"
if [ "$DETACHED" = "true" ]; then
    DOCKER_FLAGS="-d --rm"
    echo "Running in detached mode..."
fi

# Stop existing containers if any/old names
docker rm -f app-container frontend-container app 2>/dev/null || true

# 6. Run the Backend Application
echo "Starting Backend from Hub..."
echo "Running Backend: $BACKEND_IMAGE"

# Nginx expects upstream 'app'
docker run -d --rm \
  --name app \
  --network my-network \
  -e POSTGRES_HOST=postgres-container-name \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_USER=myuser \
  -e POSTGRES_DB=mydb \
  $BACKEND_IMAGE

# 7. Run the Frontend Application
echo "Starting Frontend from Hub..."
echo "Running Frontend: $FRONTEND_IMAGE"

docker run $DOCKER_FLAGS -p 80:80 \
  --name frontend-container \
  --network my-network \
  $FRONTEND_IMAGE
