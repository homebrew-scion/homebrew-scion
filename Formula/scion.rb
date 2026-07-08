class Scion < Formula
  desc "Multi-agent orchestration platform with browser-based onboarding wizard"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.2.3"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "7af23c51db48b151cdd281ff580143124d560fbd8cc92f2f51d12032132f993c"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "7c7ab4b7d5b8077926bf6cab934174de8d5dce44207ac3797b66b12c77583edb"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "a9227cc7ead63003cf48eb302197ba6d18d8bbaf08a61d205d724790f7c5f6df"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "72663af39d68226d3be99754ff29db691987db8b356a1e73c4020ce3832ffd3d"
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

      Documentation: https://github.com/GoogleCloudPlatform/scion
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
