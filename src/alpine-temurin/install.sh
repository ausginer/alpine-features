#!/usr/bin/env sh
set -eu

JAVA_VERSION="${JAVAVERSION:-lts}"

# Set locale to UTF-8
LANG='en_US.UTF-8'
LANGUAGE='en_US:en'
LC_ALL='en_US.UTF-8'

echo "export JAVA_HOME=/opt/java/openjdk" >> /etc/profile
echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> /etc/profile

export JAVA_HOME="/opt/java/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

# Install required packages for Java runtime
# 1) GPG for signature verification
# 2) CA certificates for secure connections  
# 3) Locale support for UTF-8
# 4) Timezone data for Java applications
apk add --no-cache \
  gnupg \
  ca-certificates p11-kit-trust \
  musl-locales musl-locales-lang \
  tzdata

# Install temporary packages needed for installation
apk add --no-cache --virtual .temurin-deps \
  wget \
  jq

rm -rf /var/cache/apk/* # Clean up apk cache

ARCH="$(apk --print-arch)" # Detect architecture
case "${ARCH}" in
  aarch64)
    ARCH_SUFFIX='aarch64'
    ;;
  x86_64)
    ARCH_SUFFIX='x64'
    ;;
  *)
    echo "Unsupported arch: ${ARCH}"
    exit 1
    ;;
esac

set -- $(./version.sh "$JAVA_VERSION" "$ARCH_SUFFIX") # Get version and binary URL
CHECKSUM="$1"
BINARY_URL="$2"
SIGNATURE_URL="$3"

wget -O /tmp/openjdk.tar.gz "$BINARY_URL" # Download OpenJDK binary
wget -O /tmp/openjdk.tar.gz.sig "$SIGNATURE_URL" # Download signature

export GNUPGHOME="$(mktemp -d)" # Temporary GPG home
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 3B04D753C9050D9A5D343F39843C48A565F8F04B # Import Adoptium GPG key
gpg --batch --verify /tmp/openjdk.tar.gz.sig /tmp/openjdk.tar.gz # Verify signature
rm -rf "${GNUPGHOME}" /tmp/openjdk.tar.gz.sig # Clean up GPG and signature

echo "$CHECKSUM  /tmp/openjdk.tar.gz" | sha256sum -c - # Verify checksum

mkdir -p "$JAVA_HOME" # Create JAVA_HOME directory
tar --extract --file /tmp/openjdk.tar.gz --directory "$JAVA_HOME" --strip-components 1 --no-same-owner # Extract JDK

rm -f /tmp/openjdk.tar.gz ${JAVA_HOME}/lib/src.zip # Remove archive and sources

# Create symbolic links for essential Java tools to ensure availability
ln -sf "$JAVA_HOME/bin/java" /usr/local/bin/java
ln -sf "$JAVA_HOME/bin/javac" /usr/local/bin/javac

# Verify installation
echo "Verifying install ..."
fileEncoding="$(echo 'System.out.println(System.getProperty("file.encoding"))' | jshell -s -)"; [ "$fileEncoding" = 'UTF-8' ]
rm -rf ~/.java
echo "javac --version"; javac --version
echo "java --version"; java --version

# Final cleanup - remove temporary packages
apk del .temurin-deps

echo "--- Java installation completed ---"
