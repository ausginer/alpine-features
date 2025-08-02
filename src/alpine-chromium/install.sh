#!/usr/bin/env sh
set -eu

# Update package index
apk update

# Install minimal Chromium setup for testing
apk add --no-cache \
    chromium \
    chromium-chromedriver

# Set environment variables for testing frameworks
echo "CHROME_BIN=/usr/bin/chromium-browser" >> /etc/environment
echo "CHROME_PATH=/usr/lib/chromium/" >> /etc/environment
echo "CHROMIUM_FLAGS=\
    --no-sandbox \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-extensions \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --remote-debugging-port=9222 \
" >> /etc/environment
