#!/usr/bin/env sh
set -eu

# Update package index
apk update

# Install minimal Chromium setup for testing
apk add --no-cache \
    chromium \
    chromium-chromedriver

# Set environment variables for testing frameworks
echo "export CHROME_BIN=/usr/bin/chromium-browser" >> /etc/profile
echo "export CHROME_PATH=/usr/lib/chromium/" >> /etc/profile
echo "export CHROMIUM_FLAGS=\"--no-sandbox --disable-gpu --disable-dev-shm-usage --disable-extensions --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --remote-debugging-port=9222\"" >> /etc/profile
