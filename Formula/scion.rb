class Scion < Formula
  desc "Multi-agent orchestration platform with browser-based onboarding wizard"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.2.1"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "c9ef4eeb127f0304971dd572bdcdb7ef6a419caddf6f8a0afd722664333f57b3"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "4dd174ab2a92d02cc0adaa8de4f48b65bd3805808573b4af55d623e02f4b31a5"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "a4e6e883d18618cc1618bdfa1c2258a1eabc94d5e4befae7474bf35b1c067dc4"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "f85d38c0f1657ff633386b916d038a972a10a9236355d926721382fe868a26c6"
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
  end

  def post_install
    has_runtime = system("which", "docker", out: :close, err: :close) ||
                  system("which", "podman", out: :close, err: :close)
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

      Documentation: https://github.com/GoogleCloudPlatform/scion
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
