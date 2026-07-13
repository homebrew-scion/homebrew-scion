class Scion < Formula
  desc "Multi-agent orchestration platform with browser-based onboarding wizard"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.2.6"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "861bc90dd13846fbec04e657c481d8f17510e6456556ff23bb59ebd8be4597e2"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "893b7dc912429c85c0c80676c11afd4a475bc10c0bf6f77b4a161462198c66be"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "33b33e5a764a57259f7fcf6d55f57920dbb6102eb2f546caa9fa3aec425832d2"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "c745b7bd14caf13723db592c6346678372cc13c26022d55f8d13462d1bce37c3"
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
