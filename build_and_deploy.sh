#!/bin/bash

#Exit immediately on error
set -e

source .env

SUBSTITUTION_VALUES='${DOMAIN}${EMAIL_FOR_SSL}'
envsubst "$SUBSTITUTION_VALUES" < nginx_ssl.conf.template > nginx_ssl.conf
envsubst "$SUBSTITUTION_VALUES" < nginx.conf.template > nginx.conf

# Set script vars
DOCKER_TAG="reverse-proxy"

echo "Switching builder"
docker buildx use mybuilder


echo "Building target for arm64"
docker buildx build --platform linux/arm64 -t $DOCKER_TAG . --load

echo "Stopping old container"
ssh "$PI_USER@$PI_IP" "docker stop $DOCKER_TAG " || true

echo "Removing old container"
ssh "$PI_USER@$PI_IP" "docker container rm $DOCKER_TAG " || true

echo "Grabbing current image id"
OLD_IMAGE=$(ssh "$PI_USER@$PI_IP" "docker images --filter=reference='$DOCKER_TAG' --format '{{.ID}}'")
echo $OLD_IMAGE

echo "Pushing new image"
docker save $DOCKER_TAG | bzip2 | ssh -l $PI_USER $PI_IP docker load

echo "Starting Container"
ssh "$PI_USER@$PI_IP" "docker run -d --network host -v /var/log/letsencrypt:/var/log/letsencrypt -v /etc/letsencrypt:/etc/letencrypt -v $(pwd)/nginx-logs:/var/log/nginx --restart unless-stopped --name $DOCKER_TAG \"$DOCKER_TAG\""

if [ -n "$OLD_IMAGE" ]; then
  echo "Removing old image"
  ssh "$PI_USER@$PI_IP" "docker image rm $OLD_IMAGE " || true
fi

# Restore builder
docker buildx use default