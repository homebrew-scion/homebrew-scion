# Generated from the SHA256SUMS of release v0.4.0-preview.4 by
# scripts/release/update-homebrew-formula.sh in https://github.com/GoogleCloudPlatform/scion.
# Do not edit by hand: the next release overwrites this file.
class Scion < Formula
  desc "Orchestrate concurrent LLM code agents in containers"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.4.0-preview.4"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.4/scion-darwin-arm64.tar.gz"
      sha256 "7edaeac2bd19f796cf6a1673a670ad1d22ba6f554c5cba0aaea9b42bb1eb847c"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.4/scion-darwin-amd64.tar.gz"
      sha256 "031d218460a7fd112b9e90825f882d070f5748ae12168be4b548ca69c9b57f00"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.4/scion-linux-arm64.tar.gz"
      sha256 "26f138f47b7bf0b5372e1b676646ac1b4230b3ebe4b5c0f60ee9d83e5d73111b"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.4/scion-linux-amd64.tar.gz"
      sha256 "0eaac10191dd948906c0957c78fdfd96eeef0a6e7cc56e3e30d2d728144ca5b9"
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
        ghcr.io/homebrew-scion/scion-claude:v0.4.0-preview.4
      This version of Scion pulls the images tagged with its own version.
    EOS
    if OS.linux?
      text += <<~EOS

        On Linux, Homebrew installs its own gcc, once for all formulae, when
        the system glibc is older than 2.39 or libstdc++ is older than
        6.0.33, and its own glibc as well when glibc is older than 2.39.
        Scion is a static binary and does not use them.
        On such hosts you can install the release tarball instead:
          https://github.com/GoogleCloudPlatform/scion/releases/tag/v0.4.0-preview.4
      EOS
    end
    text
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
