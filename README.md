# Alpine Linux Dev Container Features

[![](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/ausginer/alpine-features)

A collection of [Dev Container Features](https://containers.dev/features) optimized for Alpine Linux environments. These features provide lightweight, secure, and efficient development environments.

## Features

| Feature | Description | Version |
|---------|-------------|---------|
| [alpine-node](./src/alpine-node) | Node.js, npm, Yarn and pnpm on Alpine Linux | 1.0.0 |
| [alpine-temurin](./src/alpine-temurin) | Temurin JDK on Alpine Linux | 1.0.0 |
| [alpine-chromium](./src/alpine-chromium) | Minimal Chromium for headless testing | 1.0.0 |

## Usage

To reference a feature from this repository, add the desired features to a `devcontainer.json`:

```json
{
    "image": "mcr.microsoft.com/devcontainers/base:alpine",
    "features": {
        "ghcr.io/ausginer/alpine-features/alpine-node:1": {
            "nodeVersion": "22",
            "npmVersion": "latest",
            "yarnVersion": "latest"
        },
        "ghcr.io/ausginer/alpine-features/alpine-temurin:1": {
            "javaVersion": "17"
        },
        "ghcr.io/ausginer/alpine-features/alpine-chromium:1": {}
    }
}
```

## Features Overview

### alpine-node

Installs Node.js, npm, Yarn and pnpm versions for a consistent JavaScript development environment on Alpine Linux.

**Options:**
- `nodeVersion` (string): The Node.js version to install (default: "lts")
- `npmVersion` (string): The npm version to install (default: "none")
- `yarnVersion` (string): The Yarn version to install (default: "none")
- `pnpmVersion` (string): The pnpm version to install (default: "none")

### alpine-temurin

Installs Temurin JDK for a consistent Java development environment on Alpine Linux.

**Options:**
- `javaVersion` (string): The Java version to install (default: "lts")

### alpine-chromium

Installs minimal Chromium browser for headless testing and automation on Alpine Linux. Optimized for CI/CD pipelines and automated testing scenarios.

**Dependencies:**
- Installs after `ghcr.io/devcontainers/features/common-utils`

## Contributing

This repository follows the [dev container feature distribution specification](https://containers.dev/implementors/features-distribution/).

### Building and Testing

The features are automatically built and published using GitHub Actions. To test locally:

1. Clone this repository
2. Use the Dev Container CLI or VS Code to test features
3. Submit a pull request with your changes

### Adding a New Feature

1. Create a new directory under `src/` with your feature name
2. Add a `devcontainer-feature.json` file with feature metadata
3. Add an `install.sh` script that implements the installation
4. Add a `README.md` file documenting the feature
5. Update this main README with your feature information

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:
- Create an issue in this repository
- Check the [Dev Containers specification](https://containers.dev/)
- Review the [Alpine Linux documentation](https://wiki.alpinelinux.org/)
