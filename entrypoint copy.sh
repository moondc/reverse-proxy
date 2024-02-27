#!/bin/bash

# Request or renew certificates from Let's Encrypt
certbot certonly --webroot -w /var/www/html -d example.com --agree-tos --non-interactive

# Start Nginx
exec "$@"
