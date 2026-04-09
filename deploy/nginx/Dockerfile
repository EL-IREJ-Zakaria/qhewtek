FROM nginx:1.27-alpine

COPY deploy/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY web/ /var/www/web/

RUN mkdir -p /var/www/backend/uploads
