# Homebrew Distribution & Container Image Publishing

> **Status:** Draft — revised after design review with Preston (2026-05-12).

## Overview

This design covers two distribution channels for Scion that remove the "build from source" requirement:

1. **Homebrew tap** — `brew install homebrew-scion/scion/scion` installs the CLI binary.
2. **ghcr.io container images** — pre-built harness and hub images at `ghcr.io/homebrew-scion/`.

Both channels are automated: pushing a version tag to `main` on GoogleCloudPlatform/scion triggers binary releases (existing), container image publishing (new), and Homebrew formula updates (new).

## Infrastructure: The `homebrew-scion` GitHub Organization

All distribution infrastructure lives in a new GitHub organization: **`homebrew-scion`**.

| Repo | Purpose |
|------|---------|
| `homebrew-scion/homebrew-scion` | Homebrew tap — contains `Formula/scion.rb` and a README. Lightweight, fast to clone. |
| `homebrew-scion/scion` | Fork of `GoogleCloudPlatform/scion`. Runs image build and formula update automation. Synced from upstream periodically. |

This separation keeps the tap repo small (Homebrew clones it on `brew tap`) while giving the automation repo full access to Dockerfiles and build scripts.

### Why not run automation in GoogleCloudPlatform/scion?

Publishing images to `ghcr.io/homebrew-scion/` requires `packages:write` on that org. `GITHUB_TOKEN` is scoped to the repo's own org, so a workflow in `GoogleCloudPlatform/scion` would need a PAT. Running automation from `homebrew-scion/scion` keeps everything within one org where `GITHUB_TOKEN` works natively.

## 1. Homebrew Tap

### Tap Installation UX

```bash
# One-time setup
brew tap homebrew-scion/scion

# Install
brew install homebrew-scion/scion/scion

# Upgrade after a new release
brew update && brew upgrade scion
```

Homebrew resolves `brew tap homebrew-scion/scion` to `github.com/homebrew-scion/homebrew-scion` automatically — no `--branch` or URL needed.

### Formula Design

`Formula/scion.rb` in `homebrew-scion/homebrew-scion` downloads the appropriate pre-built tarball from GitHub Releases on GoogleCloudPlatform/scion.

```ruby
class Scion < Formula
  desc "Multi-agent orchestration platform"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.1.0"  # updated by automation
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "PLACEHOLDER"
    end
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "PLACEHOLDER"
    end
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "scion"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
```

### Formula Update Automation

A workflow in `homebrew-scion/scion` (the automation repo) detects new stable releases on GoogleCloudPlatform/scion and updates the formula in `homebrew-scion/homebrew-scion`.

**Trigger:** Scheduled (e.g. every 15 minutes) or via `workflow_dispatch`. The workflow checks for new releases using the GitHub API — no cross-repo webhook needed.

**Steps:**
1. Query `GoogleCloudPlatform/scion` releases via `gh api` for the latest non-prerelease.
2. Compare against the current version in `Formula/scion.rb`.
3. If newer: download tarballs, compute SHA256 checksums, update formula.
4. Clone `homebrew-scion/homebrew-scion`, commit the updated formula, push.

Cross-repo push (automation repo → tap repo) requires a fine-grained PAT or GitHub App token scoped to the `homebrew-scion` org with `contents:write` on `homebrew-scion`. Both repos are in the same org, so this is straightforward.

### macOS Gatekeeper

Per `.design/apple-binary-signing.md`, binaries installed via Homebrew bypass Gatekeeper because `brew` strips the quarantine attribute. This makes the tap a practical workaround until proper code signing is in place.

## 2. Container Image Publishing to ghcr.io

### Registry and Naming

Images are published to `ghcr.io/homebrew-scion/` under their existing names:

| Image | Description |
|-------|-------------|
| `ghcr.io/homebrew-scion/scion-base` | Base layer with scion CLI and runtime deps |
| `ghcr.io/homebrew-scion/scion-claude` | Claude harness |
| `ghcr.io/homebrew-scion/scion-gemini` | Gemini harness |
| `ghcr.io/homebrew-scion/scion-opencode` | OpenCode harness |
| `ghcr.io/homebrew-scion/scion-codex` | Codex harness |
| `ghcr.io/homebrew-scion/scion-hub` | Hub server |

`core-base` is an internal build layer and is not published.

Packages must be configured as **public** in the `homebrew-scion` org settings so users can pull without authenticating.

### Tagging Strategy

Each image is tagged with:

- **Version tag** — the git tag (e.g., `v0.3.1`). Immutable.
- **`latest`** — always points to the most recent stable (non-prerelease) release.
- **`preview`** — built on a schedule from the tip of upstream `main`. Represents bleeding-edge, potentially unstable builds for early testing.
- **Short SHA** — the git short SHA for traceability (e.g., `sha-abc1234`).

### Stable Release Workflow

Runs in `homebrew-scion/scion` when a new stable release is detected on GoogleCloudPlatform/scion (same trigger as formula updates — can be the same workflow or a parallel one).

**Steps:**
1. Sync fork from upstream (fetch the new tag).
2. Check out the tagged commit.
3. Build images using `image-build/scripts/build-images.sh --registry ghcr.io/homebrew-scion --target common --tag <version> --platform all --push`.
4. Retag all images as `latest` using `docker buildx imagetools create`.

### Pre-release Handling

When a pre-release tag is detected (GitHub Release has `prerelease: true`):

- **Images are published** with the pre-release version tag (e.g., `v0.2.0-rc1`).
- **`latest` tag is NOT updated** — it stays on the last stable release.
- **Formula is NOT updated** — `brew install scion` stays on stable.

This lets testers pull specific pre-release images without affecting the stable install path.

### Preview Builds

A scheduled workflow (e.g., nightly cron) in `homebrew-scion/scion`:

1. Syncs fork from upstream `main`.
2. Builds images with `--tag preview`.
3. Pushes with the `preview` tag (overwriting the previous preview).

No formula update. No `latest` tag movement. The `preview` tag name is cadence-agnostic — the schedule can change without the tag being misleading.

### Permissions

The automation repo needs:
- `packages:write` — for pushing images to `ghcr.io/homebrew-scion/` (provided by `GITHUB_TOKEN` since the repo is in the `homebrew-scion` org).
- A PAT or GitHub App token with `contents:write` on `homebrew-scion/homebrew-scion` — for pushing formula updates to the tap repo.

### `core-base` Exclusion

The `common` target builds `scion-base` + harnesses + hub, skipping `core-base`. This is correct — `core-base` is a build-time layer that users never pull directly. If `core-base` needs rebuilding (base OS update, etc.), a separate manual `all` build is triggered via `workflow_dispatch`.

## 3. Release Coordination

The full release pipeline when a new tag is pushed to `main` on GoogleCloudPlatform/scion:

```
Tag push (GoogleCloudPlatform/scion main)
  └─ build-release.yml (runs in GoogleCloudPlatform/scion)
       ├─ Build multi-arch binaries (linux/darwin, amd64/arm64)
       └─ Create GitHub Release with tarballs

  └─ Automation workflow (runs in homebrew-scion/scion, triggered by schedule or release detection)
       ├─ Detect new stable release on GoogleCloudPlatform/scion
       ├─ Sync fork, checkout tag
       ├─ Build & push images to ghcr.io/homebrew-scion/ with version tag
       ├─ Retag images as :latest
       └─ Update Formula/scion.rb in homebrew-scion/homebrew-scion, commit & push
```

For pre-releases, the automation workflow publishes images with the version tag only (no `latest`, no formula update).

For preview builds, a separate nightly cron builds from `main` tip and pushes the `preview` tag.

## 4. README Updates

Update `README.md` in GoogleCloudPlatform/scion (on the `homebrew` branch and eventually `main`) to replace the "build from source" messaging:

### Quick Start (revised)

```markdown
## Quick Start

### Install the CLI

**macOS / Linux (Homebrew):**

\```bash
brew tap homebrew-scion/scion
brew install homebrew-scion/scion/scion
\```

**From source (requires Go):**

\```bash
go install github.com/GoogleCloudPlatform/scion/cmd/scion@latest
\```

### Pull container images

Pre-built images are available from ghcr.io:

\```bash
scion init --registry ghcr.io/homebrew-scion
\```

Or pull images directly:

\```bash
docker pull ghcr.io/homebrew-scion/scion-claude:latest
\```
```

The note "Sadly - as an open source project we are not yet able to provide pre-built binaries or containers" should be removed.

## Trade-offs and Decisions

### Why a separate org instead of GoogleCloudPlatform?

Publishing to `ghcr.io/googlecloudplatform/` requires admin access to the GoogleCloudPlatform GitHub org to configure package visibility. Using a dedicated `homebrew-scion` org avoids this dependency and gives full control over package settings, workflow secrets, and org-level permissions.

### Why two repos in the org?

The tap repo (`homebrew-scion`) must be lightweight — Homebrew clones it on `brew tap`. Mixing in Dockerfiles, Go source, and build scripts would bloat the clone. The automation repo (a fork of upstream) has the full build system and syncs changes from upstream via `git fetch`.

### Why not goreleaser?

goreleaser would handle binary builds, GitHub Releases, and Homebrew formula updates in one tool. However:

- The existing `build-release.yml` works and embeds web assets via a custom build step (npm + go build with ldflags) that goreleaser's Go build support doesn't natively handle.
- Adding goreleaser means replacing a working workflow to gain formula automation — which is a small script.
- goreleaser can be adopted later if the release matrix grows (e.g., adding Windows, Scoop, APT/RPM repos).

### Why poll for releases instead of webhooks?

The automation repo detects new upstream releases by polling the GitHub API on a schedule. This avoids:
- Configuring webhooks on GoogleCloudPlatform/scion (requires admin access).
- Cross-repo `repository_dispatch` (requires a PAT stored in upstream).

Polling every 15 minutes is simple, reliable, and self-contained.

## Implementation Tasks

1. **Create the `homebrew-scion` GitHub org** and configure org-level settings (package visibility defaults to public).
2. **Create `homebrew-scion/homebrew-scion`** — the tap repo with `Formula/scion.rb` (placeholder SHAs) and a README.
3. **Fork GoogleCloudPlatform/scion** into `homebrew-scion/scion` — the automation repo.
4. **Write the release detection workflow** in `homebrew-scion/scion` — polls for new upstream releases, builds images, updates formula.
5. **Write the preview build workflow** in `homebrew-scion/scion` — nightly cron, builds from main tip, pushes `preview` tag.
6. **Configure auth** — create a fine-grained PAT or GitHub App for cross-repo push (automation → tap repo).
7. **Configure ghcr.io packages** as public in the `homebrew-scion` org.
8. **Update `README.md`** — revise Quick Start with `brew install` and ghcr.io instructions.
9. **End-to-end test** — push a test tag to upstream, verify: release created, images pushed to ghcr.io, formula updated, `brew install` works.

## Resolved Questions

1. **Tap repo location:** Dedicated `homebrew-scion/homebrew-scion` repo (not a branch of the main repo). Gives clean `brew tap homebrew-scion/scion` UX.
2. **Image registry:** `ghcr.io/homebrew-scion/` — published from the `homebrew-scion` org to avoid GoogleCloudPlatform admin dependencies.
3. **Automation location:** Separate `homebrew-scion/scion` fork (not in the tap repo). Keeps tap lightweight, gives automation full access to build system.
4. **Pre-release handling:** Pre-releases publish images with version tags only. No `latest` update, no formula update.
5. **Tagging:** `latest` = most recent stable release. `preview` = scheduled build from main tip. Version tags are immutable.
