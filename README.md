# Scion — Community Distribution

Community distribution of [Scion](https://github.com/GoogleCloudPlatform/scion), the multi-agent orchestration platform. This tap provides pre-built CLI binaries via Homebrew and pre-built container images on [ghcr.io](https://ghcr.io/homebrew-scion).

## Install

```bash
brew tap homebrew-scion/scion
brew install homebrew-scion/scion/scion
```

**Upgrade:**

```bash
brew update && brew upgrade scion
```

## Quick Start

```bash
scion server start
```

This starts the hub server and opens your browser to the onboarding wizard, which guides you through:
- Runtime detection (Docker, Podman, or Apple Container)
- Identity configuration
- Container image setup (automatically uses `ghcr.io/homebrew-scion`)
- Creating your first workspace

After onboarding, start an agent:

```bash
scion start my-agent "Your task here"
```

## What's Included

**`scion`** — the main CLI binary. Community builds are pre-configured to use `ghcr.io/homebrew-scion` as the default image registry.

**`scion-plugin-telegram`** — the Telegram broker plugin. Installed automatically alongside `scion`. Enables bidirectional messaging between Telegram group chats and Scion agents. See [setup instructions](https://github.com/GoogleCloudPlatform/scion/tree/main/extras/scion-telegram) and the brew install caveats for configuration.

## Container Images

Pre-built multi-arch images (`linux/amd64` + `linux/arm64`) are published to `ghcr.io/homebrew-scion/`.

### Available Images

| Image | Description |
|-------|-------------|
| `ghcr.io/homebrew-scion/scion-claude` | Claude harness |
| `ghcr.io/homebrew-scion/scion-gemini-cli` | Gemini CLI harness |
| `ghcr.io/homebrew-scion/scion-opencode` | OpenCode harness |
| `ghcr.io/homebrew-scion/scion-codex` | Codex harness |
| `ghcr.io/homebrew-scion/scion-copilot` | Copilot harness |
| `ghcr.io/homebrew-scion/scion-hermes` | Hermes harness |
| `ghcr.io/homebrew-scion/scion-antigravity` | Antigravity harness |
| `ghcr.io/homebrew-scion/scion-gen` | Gen harness |
| `ghcr.io/homebrew-scion/scion-hub` | Hub server |
| `ghcr.io/homebrew-scion/scion-base` | Base agent image |
| `ghcr.io/homebrew-scion/core-base` | Core base layer |

All images are tagged `:latest` for the current stable release. The onboarding wizard handles pulling the images you need automatically.

## Using a Custom Registry

To use your own registry instead of the community default:

```bash
scion init --machine --image-registry ghcr.io/your-org --force
```

## Apple Container Runtime

If you use Apple Container on macOS, agent connectivity requires a one-time DNS setup:

```bash
sudo container system dns create host.containers.internal --localhost 203.0.113.1
```

See the [Apple Container setup guide](https://googlecloudplatform.github.io/scion/local/apple-container/) for automating this across reboots.

## Reporting Issues

- **Scion bugs and features:** [GoogleCloudPlatform/scion/issues](https://github.com/GoogleCloudPlatform/scion/issues)
- **Tap-specific issues** (formula, images, this distribution): open an issue in this repository
