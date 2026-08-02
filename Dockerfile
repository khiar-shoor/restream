FROM alpine:latest

# Install Nginx, the RTMP module, Stunnel, and gettext (for envsubst)
RUN apk add --no-cache nginx nginx-mod-rtmp stunnel gettext

# Copy our configuration files into the container
COPY nginx.conf /etc/nginx/nginx.conf
COPY stunnel.conf /etc/stunnel/stunnel.conf
COPY start.sh /start.sh

# Make the startup script executable
RUN chmod +x /start.sh

# Expose port 8000 for Runflare
EXPOSE 8000

# Run the startup script
CMD ["/start.sh"]

