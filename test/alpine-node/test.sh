#!/bin/sh

# Test default Node.js LTS installation
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

# Check Node.js is installed
check "node version" node --version

# Check npm is available
check "npm version" npm --version

# Check that Node.js can run JavaScript
check "node execution" node -e "console.log('Hello from Node.js')"

# Report results
reportResults

# Cleanup temporary bash installation if we installed it
if [ "$CLEANUP_BASH" = "true" ]; then
  apk del .test-deps
fi
