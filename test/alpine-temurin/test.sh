#!/bin/sh

# Test default Temurin JDK installation
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

# Check Java is installed
check "java version" java -version

# Check javac compiler is available
check "javac version" javac -version

# Check JAVA_HOME is set
check "JAVA_HOME is set" test -n "$JAVA_HOME"

# Check JAVA_HOME points to a valid directory
check "JAVA_HOME directory exists" test -d "$JAVA_HOME"

# Check jlink is available (for modular Java)
check "jlink available" jlink --version

# Test basic Java compilation and execution
echo 'public class Test { public static void main(String[] args) { System.out.println("Hello from Java"); } }' > Test.java
check "compile java" javac Test.java
check "run java" java Test

# Report results
reportResults

# Cleanup temporary bash installation if we installed it
if [ "$CLEANUP_BASH" = "true" ]; then
  apk del .test-deps
fi
