class Scion < Formula
  desc "Multi-agent orchestration platform with browser-based onboarding wizard"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.2.18"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "dcb33e94fa13e30b64c3dfae44d129a2df8106353e31e5bce63b5484f12ebddf"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "cade98922ce2bb7b1119b1a4daa033d55362e607606c21559e5b640c4192149a"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "73326cd18eebda6f33e0f6ab60b2d95b9f64a22468558e5cb4776c25b5b1bc91"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "e8d15f57743807d06441230371a0a63d3b92de3a9189d8f7974c8fd6ef3af664"
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

      Telegram integration (scion-plugin-telegram) is included and configurable
      from the hub admin UI at http://127.0.0.1:8080/admin/integrations.

      Documentation: https://github.com/GoogleCloudPlatform/scion
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
