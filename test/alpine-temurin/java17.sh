#!/bin/bash

# Test Java 17 installation
set -e

# Source test library
source dev-container-features-test-lib

# Check Java version is 17.x
check "java version is 17" java -version 2>&1 | grep "17\."

# Check javac compiler is available
check "javac version" javac -version

# Check JAVA_HOME is set correctly
check "JAVA_HOME is set" test -n "$JAVA_HOME"
check "JAVA_HOME contains openjdk" echo "$JAVA_HOME" | grep openjdk

# Test basic Java compilation and execution
echo 'public class Test17 { public static void main(String[] args) { System.out.println("Hello from Java 17"); } }' > Test17.java
check "compile java 17" javac Test17.java
check "run java 17" java Test17

# Report results
reportResults
