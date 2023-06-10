apt update && apt upgrade -y
export DEBIAN_FRONTEND=noninteractive
# export DOMAIN="frani.dev" - este variable entra por Github Action Secret
apt install certbot nginx -y
apt install python-certbot-nginx -y

echo "server {
    listen 80;
    server_name ${DOMAIN};

    return 301 https://$host$request_uri;
}" >> /etc/nginx/site-enabled/default

service nginx start

