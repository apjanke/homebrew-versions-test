class Gradle27 < Formula
  desc "Gradle build automation tool"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-2.7-bin.zip"
  sha256 "cde43b90945b5304c43ee36e58aab4cc6fb3a3d5f9bd9449bb1709a68371cb06"

  bottle :unneeded

  conflicts_with "gradle", :because => "Differing version of same formula"

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end

  test do
    system "#{bin}/gradle", "-version"
  end
end
