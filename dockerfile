FROM nginx

# arm64 commands
RUN apt-get update
RUN apt-get install -y certbot

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx_ssl.conf /etc/nginx/nginx_ssl.conf
COPY .env /etc/nginx/.env

VOLUME /var/log/nginx

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
