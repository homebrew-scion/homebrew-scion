class Scion < Formula
  desc "Multi-agent orchestration platform with browser-based onboarding wizard"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.2.4"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "b23e28ede037b85dddc869825c542511685913108e6df9774732f5a0c7391928"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "a3268c4fbe2d0187712a36114974572cdb46bc7583e1a6600e57932a56a4a89e"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "3a3bec65273fd0bb0f958e8d35b6c09e8659df355f28a2f614311676d6381228"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "5494e5d6ce77054917cc3404fc33b91d38566acca3c309de1a54100f37a00cd5"
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
