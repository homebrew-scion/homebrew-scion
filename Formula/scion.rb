class Scion < Formula
  desc "Multi-agent orchestration platform"
  homepage "https://github.com/GoogleCloudPlatform/scion"
  version "0.1.0"
  license "Apache-2.0"

  on_macos do
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-darwin-amd64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-darwin-arm64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-linux-amd64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_arm do
      url "https://github.com/GoogleCloudPlatform/scion/releases/download/v#{version}/scion-linux-arm64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "scion"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/scion version")
  end
end
