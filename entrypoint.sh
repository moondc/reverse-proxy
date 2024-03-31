#!/bin/bash
set -e

source /etc/nginx/.env

FULL_DOMAIN="/var/www/$DOMAIN"

chmod -R 755 /var/log/nginx

mkdir -p $FULL_DOMAIN
mkdir -p /etc/letsencrypt
mkdir -p /var/log/letsencrypt

echo "Starting nginx in background"
nginx -c /etc/nginx/nginx.conf

attempt=0
until service nginx status 2>&1 | grep -qv "not running"; do
    echo "Waiting for Nginx to start..."
    sleep 1
    ((attempt++))
    
    if [[ $attempt -ge 5 ]]; then
        echo "Failed to start Nginx after 5 attempts."
        exit 1
    fi
done

echo "Nginx started."
echo "Fetching SSL cert"

certbot certonly --webroot -w $FULL_DOMAIN -d $DOMAIN.com -d www.$DOMAIN.com --agree-tos --email $EMAIL_FOR_SSL --non-interactive

echo "Stopping nginx for SSL configuration"

service nginx stop

attempt=0
until service nginx status 2>&1 | grep -q "not running"; do
    echo "Waiting for Nginx to stop..."
    sleep 1
    ((attempt++))
    
    if [[ $attempt -ge 5 ]]; then
        echo "Nginx failed to stop after 5 attempts."
        exit 1
    fi
done

echo "Nginx stopped, restarting with SSL in foreground mode..."

exec nginx -c /etc/nginx/nginx_ssl.conf -g 'daemon off;'