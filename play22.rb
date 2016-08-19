class Play22 < Formula
  homepage "https://www.playframework.org/"
  url "https://downloads.typesafe.com/play/2.2.6/play-2.2.6.zip"
  sha256 "f6258544472aa9a581ddf5ea2e400ff256846e6fe8204d00f29689da45ced1a3"

  bottle :unneeded

  conflicts_with "sox", :because => "both install `play` binaries"

  def install
    rm_rf Dir["**/*.bat"]
    libexec.install Dir["*"]
    bin.install_symlink libexec/"play"
  end
end
