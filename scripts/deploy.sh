#!/bin/bash

# scripts/deploy.sh
# Usage: ./deploy.sh <IMAGE_TAG> <DOCKER_REPO> [VERSION_FILE]

IMAGE_TAG=$1
DOCKER_REPO=$2
VERSION_FILE=${3:-"current_version.txt"}

# 1. Read Previous Version (Default to 'latest' if first run)
if [ -f "$VERSION_FILE" ]; then
    PREVIOUS_TAG=$(cat "$VERSION_FILE")
else
    PREVIOUS_TAG="latest"
fi

echo "---------------------------------------------------"
echo "Current running version: $PREVIOUS_TAG"
echo "Attempting to deploy: $IMAGE_TAG"
echo "---------------------------------------------------"

# Ensure run-hub.sh is executable
chmod +x run-hub.sh

# 2. Deploy New Version
# We export DETACHED=true so run-hub.sh runs in background mode
export DETACHED=true
./run-hub.sh "$IMAGE_TAG" "$DOCKER_REPO"

if [ $? -ne 0 ]; then
    echo "❌ Deployment script failed immediately."
    exit 1
fi

# 3. Wait for Startup
echo "⏳ Waiting 15s for application startup..."
sleep 15

# 4. Debug: Show container status
echo "🔍 Debugging Container Status:"
docker ps -a

# 5. Health Check
# Use a Dockerized curl to access the frontend container on the internal network
echo "🩺 Running Health Check..."
docker run --rm --network my-network curlimages/curl -f http://frontend-container/health

if [ $? -eq 0 ]; then
    echo "✅ Health check passed!"
    echo "$IMAGE_TAG" > "$VERSION_FILE"
    exit 0
else
    echo "❌ Health check failed!"
    echo "🔄 Rolling back to version: $PREVIOUS_TAG"
    
    # 6. Rollback
    ./run-hub.sh "$PREVIOUS_TAG" "$DOCKER_REPO"
    
    if [ $? -eq 0 ]; then
        echo "✅ Rollback successful."
        # Exit 1 to signal failure to Jenkins (so it sends the Slack Alert)
        exit 1
    else
        echo "⛔ CRITICAL: Rollback failed!"
        exit 2
    fi
fi
