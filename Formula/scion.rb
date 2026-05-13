class Scion < Formula
  desc "Multi-agent orchestration platform"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.1.0"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "b05644c9b21eb355e9362440448655552d276007eaa15ade7dfb2b84d6bffc12"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "749be38fe557306275a6a21d0aa41262b6bd5036e7eaac8d40d3e1dd93d87962"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "f6e0030192b59b36be96c87238e607749d1ffca38e0dfe1c7611ce095344228d"
    end
    on_arm do
      url "https://github.com/homebrew-scion/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "b7ee96ec24cd8f6582fb14bcfabde91d88ead03adabebd9c75f56d20df877b77"
    end
  end

  def install
    bin.install "scion"
  end

  def post_install
    # Warn if no container runtime is available
    has_runtime = system("which", "docker", out: :close, err: :close) ||
                  system("which", "podman", out: :close, err: :close)
    unless has_runtime
      opoo "No container runtime found. Install Docker Desktop or Podman before running agents.\n" \
           "  Docker:  https://www.docker.com/products/docker-desktop/\n" \
           "  Podman:  https://podman.io/"
    end

    # Seed ~/.scion/ with default config and the community registry (ghcr.io/homebrew-scion).
    # Safe to run on reinstall/upgrade — skips files that already exist.
    system "#{bin}/scion", "init", "--machine", "--non-interactive"
  end

  def caveats
    <<~EOS
      Scion machine config has been seeded in ~/.scion/ with the community
      registry (ghcr.io/homebrew-scion) pre-configured.

      To start using Scion in a project:
        cd your-project
        scion init
        scion server start

      To use a different container registry:
        scion init --machine --image-registry ghcr.io/your-org --force

      Documentation: https://github.com/GoogleCloudPlatform/scion
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
