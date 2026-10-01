#!/bin/sh

if [ -z "$PLATFORMS" ]; then
    PLATFORMS="twitch, kick, youtube"
fi

export PUSH_TWITCH=""
export PUSH_KICK=""
export PUSH_YOUTUBE=""
START_STUNNEL=0

# Check for Twitch
if echo "$PLATFORMS" | grep -iq "twitch"; then
    export PUSH_TWITCH="push rtmp://ingest.global-contribute.live-video.net/app/${TWITCH_KEY};"
fi

# Check for Kick
if echo "$PLATFORMS" | grep -iq "kick"; then
    export PUSH_KICK="push rtmp://127.0.0.1:1936/app/${KICK_KEY};"
    START_STUNNEL=1
fi

# Check for YouTube
if echo "$PLATFORMS" | grep -iq "youtube"; then
    export PUSH_YOUTUBE="push rtmp://a.rtmp.youtube.com/live2/${YOUTUBE_KEY};"
fi

# Password Authentication Check (Optional)
if [ -n "$OBS_STREAM_KEY" ]; then
    # Password set in Runflare: Enforce exact match
    export AUTH_CHECK="if (\$arg_name = '$OBS_STREAM_KEY') { return 200; } return 403;"
else
    # No password set: Allow any stream key
    export AUTH_CHECK="return 200;"
fi

# Inject variables into nginx.conf
envsubst '$PUSH_TWITCH $PUSH_KICK $PUSH_YOUTUBE $AUTH_CHECK' < /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp
mv /etc/nginx/nginx.conf.tmp /etc/nginx/nginx.conf

# Start Stunnel if Kick is enabled
if [ "$START_STUNNEL" -eq 1 ]; then
    stunnel /etc/stunnel/stunnel.conf &
fi

# Start Nginx
nginx -g 'daemon off;'