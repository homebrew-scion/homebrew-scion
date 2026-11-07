# Generated from the SHA256SUMS of release v0.3.0-preview.6 by
# scripts/release/update-homebrew-formula.sh in https://github.com/GoogleCloudPlatform/scion.
# Do not edit by hand: the next release overwrites this file.
class Scion < Formula
  desc "Orchestrate concurrent LLM code agents in containers"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.3.0-preview.6"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.6/scion-darwin-arm64.tar.gz"
      sha256 "a55363655b101d5b09567537f03e9a6195a1c32b77aae71601ca26506dc5fe9b"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.6/scion-darwin-amd64.tar.gz"
      sha256 "d9b8c240a891611c178cd9f762524bbc3f09f4741ff8d8dbeeb69a77c1b34824"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.6/scion-linux-arm64.tar.gz"
      sha256 "d324685c31716cfd4e204c03e848d1a5f96fbb7f54863bafe8c9124a68a3b8e7"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.6/scion-linux-amd64.tar.gz"
      sha256 "2ef0ab1530b7341e1170ac58bcd58656233bc9f2382e63f52f9fed37429f2d9d"
    end
  end

  def install
    bin.install "scion"
  end

  def caveats
    text = <<~EOS
      To set up Scion, start the workstation server:
        scion server start
      On first start it opens the onboarding wizard, which checks your
      container runtime and sets the image registry.

      If a server was already running, restart it to use the new binary:
        scion server restart

      Container images for this release are published with the release tag,
      for example:
        ghcr.io/homebrew-scion/scion-claude:v0.3.0-preview.6
      Until Scion resolves images by release tag, it pulls :latest, which in
      ghcr.io/homebrew-scion is an old v0.2 image (newer harnesses have
      none). To match this version, build the images locally or set
      image_registry to a registry with current images.
    EOS
    if OS.linux?
      text += <<~EOS

        On Linux, Homebrew installs its own gcc, once for all formulae, when
        the system glibc is older than 2.39 or libstdc++ is older than
        6.0.33, and its own glibc as well when glibc is older than 2.39.
        Scion is a static binary and does not use them.
        On such hosts you can install the release tarball instead:
          https://github.com/GoogleCloudPlatform/scion/releases/tag/v0.3.0-preview.6
      EOS
    end
    text
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
