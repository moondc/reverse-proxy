FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
VOLUME /var/log/nginx
CMD /bin/sh -c "chmod -R 755 /var/log/nginx && nginx -g 'daemon off;'"
