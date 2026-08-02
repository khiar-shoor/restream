#!/bin/sh

# If PLATFORMS is completely empty, default to streaming to both
if [ -z "$PLATFORMS" ]; then
    PLATFORMS="twitch, kick"
fi

export PUSH_TWITCH=""
export PUSH_KICK=""
START_STUNNEL=0

# Check for Twitch (case-insensitive)
if echo "$PLATFORMS" | grep -iq "twitch"; then
    # We evaluate the TWITCH_KEY right here and prepare the config line
    export PUSH_TWITCH="push rtmp://ingest.global-contribute.live-video.net/app/${TWITCH_KEY};"
fi

# Check for Kick (case-insensitive)
if echo "$PLATFORMS" | grep -iq "kick"; then
    export PUSH_KICK="push rtmp://127.0.0.1:1936/app/${KICK_KEY};"
    START_STUNNEL=1
fi

# Inject the prepared push lines into the Nginx config
envsubst < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp
mv /etc/nginx/nginx.conf.tmp /etc/nginx/nginx.conf

# Start Stunnel ONLY if Kick was requested
if [ "$START_STUNNEL" -eq 1 ]; then
    stunnel /etc/stunnel/stunnel.conf &
fi

# Start Nginx in the foreground
nginx -g 'daemon off;'