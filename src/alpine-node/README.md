# Node.js on Alpine (alpine-node)

Installs Node.js, npm, Yarn and pnpm versions for a consistent JavaScript development environment on Alpine Linux.

## Example Usage

```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-node:1": {
        "nodeVersion": "18",
        "npmVersion": "latest",
        "yarnVersion": "latest",
        "pnpmVersion": "latest"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|------------|-------------|------|---------------|
| nodeVersion | The Node.js version to install | string | lts |
| npmVersion | The npm version to install. Set to 'none' to proceed with default installation | string | none |
| yarnVersion | The Yarn version to install. Set to 'none' to skip | string | none |
| pnpmVersion | The pnpm version to install. Set to 'none' to skip | string | none |

## Supported Node.js Versions

- `lts` - Latest LTS version
- `latest` - Latest stable version  
- `18`, `20`, `21` - Specific major versions
- `18.17.0` - Specific exact versions

## Package Managers

This feature can install multiple Node.js package managers:

### npm
- Installed by default with Node.js
- Can be upgraded to a specific version
- Set `npmVersion` to "none" to keep the default version

### Yarn
- Modern package manager with workspace support
- Set `yarnVersion` to "latest" or specific version like "1.22.19"
- Set to "none" to skip installation

### pnpm
- Fast, disk space efficient package manager
- Set `pnpmVersion` to "latest" or specific version like "8.6.0"  
- Set to "none" to skip installation

## Examples

### Basic Node.js LTS
```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-node:1": {}
}
```

### Node.js 18 with Yarn
```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-node:1": {
        "nodeVersion": "18",
        "yarnVersion": "latest"
    }
}
```

### Node.js Latest with all package managers
```json
"features": {
    "ghcr.io/ausginer/alpine-features/alpine-node:1": {
        "nodeVersion": "latest",
        "npmVersion": "latest",
        "yarnVersion": "latest", 
        "pnpmVersion": "latest"
    }
}
```

## Implementation Details

This feature:
- Downloads Node.js from the official Node.js distribution
- Verifies GPG signatures for security
- Installs to `/usr/local` following Alpine conventions
- Sets up proper PATH configuration
- Installs additional package managers as requested
- Optimized for Alpine Linux musl libc

## Notes

- Based on the official Node.js Docker Alpine images
- Includes GPG signature verification for security
- Compatible with Alpine Linux 3.14+
- Automatically configures environment variables
