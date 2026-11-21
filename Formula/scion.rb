# Generated from the SHA256SUMS of release v0.4.0-preview.3 by
# scripts/release/update-homebrew-formula.sh in https://github.com/GoogleCloudPlatform/scion.
# Do not edit by hand: the next release overwrites this file.
class Scion < Formula
  desc "Orchestrate concurrent LLM code agents in containers"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.4.0-preview.3"
  license "Apache-2.0"

  on_macos do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.3/scion-darwin-arm64.tar.gz"
      sha256 "ecde514fd27047023c065db4852695f3699709d28dc5e48d3a7869d7b51cb41b"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.3/scion-darwin-amd64.tar.gz"
      sha256 "b8b8cc9f0efc6d652d1cac5c44f6f3addc9b964dd6e38f18d0aaaa191eda14cb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.3/scion-linux-arm64.tar.gz"
      sha256 "d6605b68455455136e69c41ade4220916faf7d60a29f4b10af9730dd8698b932"
    end
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v0.4.0-preview.3/scion-linux-amd64.tar.gz"
      sha256 "d210505c58393f68ae719bc6185e71a3f0455caa1dce6e7798d6bc355663e17f"
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
        ghcr.io/homebrew-scion/scion-claude:v0.4.0-preview.3
      This version of Scion pulls the images tagged with its own version.
    EOS
    if OS.linux?
      text += <<~EOS

        On Linux, Homebrew installs its own gcc, once for all formulae, when
        the system glibc is older than 2.39 or libstdc++ is older than
        6.0.33, and its own glibc as well when glibc is older than 2.39.
        Scion is a static binary and does not use them.
        On such hosts you can install the release tarball instead:
          https://github.com/GoogleCloudPlatform/scion/releases/tag/v0.4.0-preview.3
      EOS
    end
    text
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
