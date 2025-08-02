#!/usr/bin/env sh
set -eu
# This script installs Node.js and optionally npm, Yarn, and pnpm on Alpine Linux.
# Copyright https://github.com/nodejs/docker-node/blob/bd31952b241c9e57ff2205294a87dbb55fdb2f26/22/alpine3.22/Dockerfile

# --- Arguments ---
NODE_VERSION="${NODEVERSION:-lts}"
NPM_VERSION="${NPMVERSION:-none}"
YARN_VERSION="${YARNVERSION:-none}"
PNPM_VERSION="${PNPMVERSION:-none}"

echo "--- Starting Node.js installation on Alpine (verbose) ---"
echo "Node Version: ${NODE_VERSION}"
echo "NPM Version: ${NPM_VERSION}"
echo "Yarn Version: ${YARN_VERSION}"
echo "pnpm Version: ${PNPM_VERSION}"

# Install Node.js and dependencies
apk add --no-cache libstdc++  # Install C++ standard library

# Install temporary packages needed for installation
apk add --no-cache --virtual .node-deps \
  wget \
  ca-certificates \
  jq

# Set architecture variables
ARCH=
OPENSSL_ARCH='linux*'
ALPINE_ARCH="$(apk --print-arch)"

case "${ALPINE_ARCH##*-}" in
  x86_64)
    ARCH='x64'
    OPENSSL_ARCH=linux-x86_64
    ;;
  x86)
    OPENSSL_ARCH=linux-elf
    ;;
  aarch64)
    OPENSSL_ARCH=linux-aarch64
    ;;
  arm*)
    OPENSSL_ARCH=linux-armv4
    ;;
  ppc64le)
    OPENSSL_ARCH=linux-ppc64le
    ;;
  s390x)
    OPENSSL_ARCH=linux-s390x
    ;;
  *)
    ;;
esac

PARSED_VERSION="$(./version.sh "$NODE_VERSION")"

if [ $ARCH == 'x64' ]; then
  # Download Node.js binary tarball
  wget -q --show-progress --https-only --no-check-certificate "https://unofficial-builds.nodejs.org/download/release/v$PARSED_VERSION/SHASUMS256.txt"
  wget -q --show-progress --https-only --no-check-certificate "https://unofficial-builds.nodejs.org/download/release/v$PARSED_VERSION/node-v$PARSED_VERSION-linux-$ARCH-musl.tar.xz"
  # Verify checksum (BusyBox compatible)
  grep "node-v$PARSED_VERSION-linux-$ARCH-musl.tar.xz" SHASUMS256.txt | sha256sum -c - || { echo "Checksum verification failed"; exit 1; }
  # Extract Node.js to /usr/local
  tar -xJf "node-v$PARSED_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner
  # Symlink nodejs binary
  ln -s /usr/local/bin/node /usr/local/bin/nodejs
  # Clean up
  rm -f "node-v$PARSED_VERSION-linux-$ARCH-musl.tar.xz" SHASUMS256.txt
else
  echo "Building from source"
  # Install additional build dependencies (wget/ca-certificates already installed above)
  apk add --no-cache --virtual .build-deps-full \
    binutils-gold \
    g++ \
    gcc \
    gnupg \
    libgcc \
    linux-headers \
    make \
    python3 \
    py-setuptools
  # Use pre-existing gpg directory
  export GNUPGHOME="$(mktemp -d)"
  # Import Node.js release keys
  for key in \
    C0D6248439F1D5604AAFFB4021D900FFDB233756 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
    A363A499291CBBC940DD62E41F10027AF002F8B0 \
  ; do
    { gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" && gpg --batch --fingerprint "$key"; } ||
    { gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" && gpg --batch --fingerprint "$key"; }
  done
  # Download Node.js source and signature
  wget -q --show-progress --https-only --no-check-certificate "https://nodejs.org/dist/v$PARSED_VERSION/node-v$PARSED_VERSION.tar.xz"
  wget -q --show-progress --https-only --no-check-certificate "https://nodejs.org/dist/v$PARSED_VERSION/SHASUMS256.txt.asc"
  # Decrypt signature file
  gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
  # Kill gpg agent and cleanup
  gpgconf --kill all
  # Verify source tarball checksum
  grep " node-v$PARSED_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c -
  # Extract source
  tar -xf "node-v$PARSED_VERSION.tar.xz"
  # Clean up source archive immediately
  rm -rf "node-v$PARSED_VERSION.tar.xz" SHASUMS256.txt "$GNUPGHOME" SHASUMS256.txt.asc
  cd "node-v$PARSED_VERSION"
  # Configure and build Node.js
  ./configure
  make -j$(getconf _NPROCESSORS_ONLN) V=
  make install
  # Remove build dependencies
  apk del .build-deps-full
  cd ..
  # Cleanup source directory
  rm -rf "node-v$PARSED_VERSION"
fi

# Remove unused OpenSSL headers to save space
find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \;

# Smoke tests for Node.js and npm
node --version
npm --version

# Install npm if specified
if [ "${NPM_VERSION}" != "none" ]; then
  echo "Installing npm version: ${NPM_VERSION}"
  npm install -g corepack
  corepack enable
  corepack prepare npm@"${NPM_VERSION}" --activate
  echo "npm version: $(npm --version)"
else
  echo "Skipping npm installation as version is set to 'none'."
fi

if [ "${YARN_VERSION}" != "none" ]; then
  echo "Installing Yarn version: ${YARN_VERSION}"
  # Install corepack to manage Yarn versions
  npm install -g corepack
  corepack enable
  corepack prepare yarn@"${YARN_VERSION}" --activate
  echo "yarn version: $(yarn --version)"
else
  echo "Skipping Yarn installation as version is set to 'none'."
fi

# Install pnpm if specified
if [ "${PNPM_VERSION}" != "none" ]; then
  echo "Installing pnpm version: ${PNPM_VERSION}"
  npm install -g corepack
  corepack enable
  corepack prepare pnpm@"${PNPM_VERSION}" --activate
  echo "pnpm version: $(pnpm --version)"
else
  echo "Skipping pnpm installation as version is set to 'none'."
fi

# Final cleanup - remove temporary packages
apk del .node-deps

echo "--- Node.js installation completed ---"
