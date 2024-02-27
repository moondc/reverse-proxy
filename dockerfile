FROM nginx
# RUN apt update
# RUN apt install -y certbot
# RUN mkdir -p /var/www/html
COPY nginx.conf /etc/nginx/nginx.conf
VOLUME /var/log/nginx
# COPY entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
CMD /bin/sh -c "chmod -R 755 /var/log/nginx && nginx -g 'daemon off;'"
