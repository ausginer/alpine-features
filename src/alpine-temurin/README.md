# Temurin on Alpine (alpine-temurin)

Installs minimal Eclipse Temurin JDK optimized for containerized Java development on Alpine Linux. Designed for headless environments, microservices, and cloud-native applications.

## Example Usage

```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-temurin:1": {
        "javaVersion": "17"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|------------|-------------|------|---------------|
| javaVersion | The Java version to install | string | lts |

## Supported Java Versions

- `lts` - Latest LTS version (currently Java 21)
- `latest` - Latest stable version
- `8`, `11`, `17`, `21` - Specific major versions
- `17.0.7` - Specific exact versions

## What's Installed

This feature installs:
- **Eclipse Temurin JDK** - OpenJDK distribution by the Eclipse Foundation
- **Certificate support** - CA certificates for secure HTTPS connections
- **Locale support** - UTF-8 locale configuration for proper text handling
- **Timezone data** - Complete timezone database for Java applications

## Environment Variables

The following environment variables are configured:

- `JAVA_HOME=/opt/java/openjdk` - Java installation directory
- `PATH` - Updated to include `$JAVA_HOME/bin`
- `LANG=en_US.UTF-8` - Locale configuration
- `LC_ALL=en_US.UTF-8` - Full locale support

## Examples

### Default LTS Java
```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-temurin:1": {}
}
```

### Java 17
```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-temurin:1": {
        "javaVersion": "17"
    }
}
```

### Java 11
```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-temurin:1": {
        "javaVersion": "11"
    }
}
```

## Implementation Details

This feature:
- Downloads Temurin JDK from Eclipse Adoptium
- Verifies GPG signatures for security
- Installs to `/opt/java/openjdk` following FHS conventions
- Configures system-wide environment variables
- Minimal installation optimized for containerized environments
- Headless-ready (no GUI font dependencies)
- Optimized for Alpine Linux musl libc

## Security Features

- GPG signature verification of downloaded JDK
- Uses official Eclipse Adoptium sources
- Includes up-to-date CA certificates
- Follows Alpine Linux security best practices

## Compatibility

- Compatible with Alpine Linux 3.14+
- Supports musl libc (Alpine's C library)
- Works with both containerized and non-containerized environments
- Includes timezone data for proper date/time handling
