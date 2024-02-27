#!/bin/bash
#Exit immediately on error
set -e

# Set script vars
DOCKER_TAG="reverse-proxy"

# Build docker image
echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG . --load
echo "Build finished"

# # Stop old containers
# echo "Stopping all old containers"
# OLD_IMAGES=$(ssh "$PI_USER@$PI_IP" 'docker images --filter "reference=$DOCKER_TAG*" --format "{{.ID}}"')
# for OLD_IMAGE in $OLD_IMAGES; do
#     CONTAINER_IDS=$(ssh "$PI_USER@$PI_IP" "docker ps -q --filter ancestor='$OLD_IMAGE'")
#     for CONTAINER_ID in $CONTAINER_IDS; do
#         ssh "$PI_USER@$PI_IP" "docker stop '$CONTAINER_ID'"
#     done
# done
# echo "Done stopping old containers"

# # Prune old containers and images
# echo "Pruning all stopped containers and deleting unused images"
# DELETED_ITEMS=$(ssh "$PI_USER@$PI_IP" "docker system prune -a -f")
# echo $DELETED_ITEMS
# echo "Done pruning"

# Push image to remote server
echo "Pushing to remote"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $PI_IP docker load
echo "Done pushing"


# Start container with auto restart
echo "Starting Container"
STARTED_CONTAINER=$(ssh "$PI_USER@$PI_IP" "docker run -d --network host -v $(pwd)/nginx-logs:/var/log/nginx --restart unless-stopped \"$DOCKER_TAG\"")
echo "Started container:$STARTED_CONTAINER"