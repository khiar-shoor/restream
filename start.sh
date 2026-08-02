#!/bin/sh

# Inject your stream keys into the Nginx config at startup
envsubst < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp
mv /etc/nginx/nginx.conf.tmp /etc/nginx/nginx.conf

# Start Stunnel in the background for Kick
stunnel /etc/stunnel/stunnel.conf &

# Start Nginx in the foreground
nginx -g 'daemon off;'
