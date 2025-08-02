#!/bin/sh

# Test Chromium installation
set -e

# Install bash temporarily for testing (if not already available)
if ! command -v bash >/dev/null 2>&1; then
  apk add --no-cache --virtual .test-deps bash
  CLEANUP_BASH=true
fi

# Re-execute this script with bash for the test library
if [ "$1" != "--bash-mode" ]; then
  exec bash "$0" --bash-mode "$@"
fi

# Now we're running in bash mode
# Source test library
source dev-container-features-test-lib

# Check Chromium is installed
check "chromium-browser available" command -v chromium-browser

# Check ChromeDriver is installed  
check "chromedriver available" command -v chromedriver

# Check Chromium version
check "chromium version" chromium-browser --version

# Check ChromeDriver version
check "chromedriver version" chromedriver --version

# Report results
reportResults

# Cleanup temporary bash installation if we installed it
if [ "$CLEANUP_BASH" = "true" ]; then
  apk del .test-deps
fi
