# Scion — Community Distribution

Community distribution of [Scion](https://github.com/GoogleCloudPlatform/scion), the multi-agent orchestration platform. This tap provides pre-built CLI binaries via Homebrew and pre-built container images on [ghcr.io](https://ghcr.io/homebrew-scion).

## Install the CLI

**Stable (recommended):**

```bash
brew tap homebrew-scion/scion
brew install homebrew-scion/scion/scion
scion version
```

**Upgrade:**

```bash
brew update && brew upgrade scion
```

## Container Images

Pre-built container images are published to `ghcr.io/homebrew-scion/`. There are two tracks:

### Stable

Tagged as `latest` or `:<version>` (e.g., `:v0.3.1`). Updated automatically when a new stable release is tagged upstream.

Images: `core-base`, `scion-base`, `scion-claude`, `scion-gemini`, `scion-opencode`, `scion-codex`, `scion-hub`

```bash
docker pull ghcr.io/homebrew-scion/scion-claude:latest
```

### Preview

Tagged as `:preview`. Built nightly from the latest upstream `main` branch. May be unstable — useful for testing new features before they are released.

```bash
docker pull ghcr.io/homebrew-scion/scion-claude:preview
```

## Quick Start

```bash
# 1. Initialize machine-level config (sets up ~/.scion/)
#    Community builds default to ghcr.io/homebrew-scion automatically
scion init --machine

# 2. Initialize a project in your repo
cd your-project
scion init

# 3. Start the hub server
scion server start

# 4. Start an agent
scion start my-agent "Your task here"
```

Community binaries automatically default to `ghcr.io/homebrew-scion` as the image registry when running `scion init --machine` — no `--image-registry` flag needed.

## Manual Registry Override

To use your own registry instead of the default:

```bash
scion init --machine --image-registry ghcr.io/your-org
```

## Reporting Issues

For bugs and feature requests, please file an issue on the main project repository:

https://github.com/GoogleCloudPlatform/scion/issues

This tap is community-maintained. For tap-specific issues (formula, images), open an issue in this repository.
