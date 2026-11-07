# Generated from the SHA256SUMS of release v0.3.0-preview.7 by
# scripts/release/update-homebrew-formula.sh in https://github.com/GoogleCloudPlatform/scion.
# Do not edit by hand: the next release overwrites this file.
class Scion < Formula
  desc "Orchestrate concurrent LLM code agents in containers"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.3.0-preview.7"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.7/scion-darwin-arm64.tar.gz"
      sha256 "aca94a7f83e309e954277ec084beb0f91f01a9944ed260c8e1ea5677c9480780"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.7/scion-darwin-amd64.tar.gz"
      sha256 "81fae8f72c0070d053af79205ee8e13abed37590aaefc87ac5204706aa441cad"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.7/scion-linux-arm64.tar.gz"
      sha256 "09b0bc16d8eae1e435c8947a9fb31ad9df26c4f876fd92e899723fa83f0754a9"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.3.0-preview.7/scion-linux-amd64.tar.gz"
      sha256 "3d660e5f53d9130a79daa6eec129f994a148e38c7c23040936e45ed38c15c40d"
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
        ghcr.io/homebrew-scion/scion-claude:v0.3.0-preview.7
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
          https://github.com/GoogleCloudPlatform/scion/releases/tag/v0.3.0-preview.7
      EOS
    end
    text
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
