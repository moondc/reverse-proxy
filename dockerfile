# First stage: Create the .htpasswd file
FROM httpd:2.4 as auth-builder
ARG USER
ARG PASSWORD

RUN apt-get update && apt-get install -y apache2-utils
RUN htpasswd -cb /usr/local/apache2/.htpasswd $USER $PASSWORD

FROM nginx

# arm64 commands
RUN apt-get update
RUN apt-get install -y certbot

COPY --from=auth-builder /usr/local/apache2/.htpasswd /etc/nginx/.htpasswd

COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx_ssl.conf /etc/nginx/nginx_ssl.conf
COPY .env /etc/nginx/.env

VOLUME /var/log/nginx

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
