class ScionWorkstation < Formula
  desc "Scion CLI — workstation-improvements experimental branch (builds from source)"
  homepage "https://github.com/ptone/scion/tree/workstation-improvements"
  license "Apache-2.0"
  head "https://github.com/ptone/scion.git", branch: "workstation-improvements"

  depends_on "go" => :build

  conflicts_with "scion", because: "both install a 'scion' binary"

  def install
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

  def post_install
    has_runtime = system("which", "docker", out: :close, err: :close) ||
                  system("which", "podman", out: :close, err: :close)
    unless has_runtime
      opoo "No container runtime found. Install Docker Desktop or Podman before running agents.\n" \
           "  Docker:  https://www.docker.com/products/docker-desktop/\n" \
           "  Podman:  https://podman.io/"
    end

    system "#{bin}/scion", "init", "--machine", "--non-interactive"
  end

  def caveats
    <<~EOS
      This is an experimental build from the workstation-improvements branch.
      It is NOT the stable release — use 'scion' for production.

      To install:
        brew install --HEAD homebrew-scion/scion/scion-workstation

      To upgrade to the latest commit on the branch:
        brew reinstall --HEAD homebrew-scion/scion/scion-workstation

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
