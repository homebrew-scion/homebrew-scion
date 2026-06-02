class ScionWorkstation < Formula
  desc "Scion CLI — workstation-improvements experimental branch (builds from source)"
  homepage "https://github.com/ptone/scion/tree/workstation-improvements"
  license "Apache-2.0"
  head "https://github.com/ptone/scion.git", branch: "workstation-improvements"

  depends_on "go" => :build
  depends_on "node" => :build

  conflicts_with "scion", because: "both install a 'scion' binary"

  def install
    # Build the web frontend first — Go embeds web/dist/client/ at compile time.
    # Without this step the binary has no web UI and scion server start fails.
    system "npm", "install", "--prefix", "web"
    system "npm", "run", "build", "--prefix", "web"

    registry = "ghcr.io/homebrew-scion"
    ldflags = %W[
      -s -w
      -X github.com/GoogleCloudPlatform/scion/pkg/version.DefaultRegistry=#{registry}
    ]
    system "go", "build", "-buildvcs=false",
           "-ldflags", ldflags.join(" "),
           "-o", bin/"scion",
           "./cmd/scion"
  end

  # Stop the running daemon before uninstall so ports are freed for a reinstall.
  def pre_uninstall
    system bin/"scion", "server", "stop", out: :close, err: :close
  rescue
    nil
  end

  def post_install
    has_runtime = system("which", "docker", out: :close, err: :close) ||
                  system("which", "podman", out: :close, err: :close)
    unless has_runtime
      opoo "No container runtime found. Install Docker Desktop or Podman before running agents.\n" \
           "  Docker:  https://www.docker.com/products/docker-desktop/\n" \
           "  Podman:  https://podman.io/"
    end

    unless system bin/"scion", "init", "--machine", "--non-interactive",
                              "--image-registry", "ghcr.io/homebrew-scion"
      opoo "scion init --machine failed. Run manually after install:\n" \
           "  scion init --machine --non-interactive --image-registry ghcr.io/homebrew-scion"
    end
  end

  def caveats
    <<~EOS
      This is an experimental build from the workstation-improvements branch.
      It is NOT the stable release — use 'scion' for production.

      To start Scion and open the onboarding wizard:
        scion server start

      To upgrade to the latest commit on the branch:
        brew reinstall --HEAD homebrew-scion/scion/scion-workstation

      To reset and reinstall cleanly:
        scion server stop || true
        brew uninstall scion-workstation && rm -rf ~/.scion
        brew install --HEAD homebrew-scion/scion/scion-workstation

      To switch back to the stable release:
        brew uninstall scion-workstation
        brew install homebrew-scion/scion/scion
    EOS
  end

  test do
    assert_predicate bin/"scion", :exist?
    system bin/"scion", "version"
  end
end
