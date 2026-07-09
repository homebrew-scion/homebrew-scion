class Scion < Formula
  desc "Multi-agent orchestration platform with browser-based onboarding wizard"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.2.5"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "40357ce92c1d84ae81eaaabbe306866921dbec348a7f702b6f322703d79d48ba"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "c2edb0a60d976d93bc18d69185ab6b2caa67a5ca53db047374b6cbc74d5114bb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "2dcd708a9869a60c0fb1aa87764c82cfca0b3fff29e799dd03adcd79fa0748e6"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "6652e31f13def4aafbc18f3f902c2ed21838a2b0b26d8db47f0b93f419f64688"
    end
  end

  # Stop any running scion server before install or upgrade so ports are free.
  def pre_install
    if (old_bin = HOMEBREW_PREFIX/"bin/scion").exist?
      system old_bin, "server", "stop", out: :close, err: :close
    end
  rescue
    nil
  end

  def install
    bin.install "scion"
    libexec.install "scion-plugin-telegram"
    bin.install_symlink libexec/"scion-plugin-telegram"
  end

  def post_install
    has_runtime = which("docker") || which("podman")
    unless has_runtime
      opoo "No container runtime found. Install Docker Desktop or Podman before running agents.\n" \
           "  Docker:  https://www.docker.com/products/docker-desktop/\n" \
           "  Podman:  https://podman.io/"
    end

    # Pre-detect runtime and write settings.yaml. This prevents apple-container from
    # being auto-detected at server startup (which causes a crash on macOS due to
    # authorization requirements). The onboarding wizard still runs via the SPA's
    # client-side status check.
    unless system bin/"scion", "init", "--machine", "--non-interactive",
                              "--image-registry", "ghcr.io/homebrew-scion"
      opoo "scion init --machine failed. Run manually:\n" \
           "  scion init --machine --non-interactive --image-registry ghcr.io/homebrew-scion"
    end
  end

  def caveats
    <<~EOS
      Scion has been installed. To get started, run:

        scion server start

      This starts the hub and opens the browser to the onboarding wizard,
      which guides you through runtime setup, harness selection, image pulling,
      and creating your first workspace.

      To use a different container registry:
        scion init --machine --image-registry ghcr.io/your-org --force

      ── Telegram Integration ──────────────────────────────────────────────
      The Telegram broker plugin (scion-plugin-telegram) is included.
      To enable Telegram messaging for your hub:

        1. Create a bot via @BotFather (https://t.me/BotFather).
        2. Disable bot privacy mode in BotFather so it can read group messages:
             /mybots → select bot → Bot Settings → Group Privacy → Turn OFF
           Then remove and re-add the bot to any existing groups.
        3. Add to your hub's ~/.scion/settings.yaml:
             server:
               message_broker:
                 enabled: true
                 types: [telegram]
             plugins:
               broker:
                 telegram:
                   config:
                     bot_token: "YOUR_BOT_TOKEN"
                     inbound_mode: poll
                     db_path: "~/.scion/telegram_v2.db"
        4. Set the environment variable and restart:
             export SCION_TELEGRAM_V2=1
             scion server stop && scion server start
        5. Add the bot to a Telegram group and mention it to test.

      Full docs: https://github.com/GoogleCloudPlatform/scion/tree/main/extras/scion-telegram
      ─────────────────────────────────────────────────────────────────────

      Documentation: https://github.com/GoogleCloudPlatform/scion
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
