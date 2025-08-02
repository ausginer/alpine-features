#!/bin/sh

# Test Node.js 22 with Yarn installation
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

# Check Node.js version is 22.x
check "node version starts with v22" node --version | grep "^v22"

# Check npm is available
check "npm version" npm --version

# Check Yarn is installed
check "yarn version" yarn --version

# Check pnpm is installed
check "pnpm version" pnpm --version

# Check that all package managers work
check "node execution" node -e "console.log('Hello from Node.js')"
check "npm execution" npm --version
check "yarn execution" yarn --version
check "pnpm execution" pnpm --version

# Report results
reportResults

# Cleanup temporary bash installation if we installed it
if [ "$CLEANUP_BASH" = "true" ]; then
  apk del .test-deps
fi
