class Gradle221 < Formula
  desc "Build system based on the Groovy language"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-2.2.1-bin.zip"
  sha256 "420aa50738299327b611c10b8304b749e8d3a579407ee9e755b15921d95ff418"

  bottle :unneeded

  conflicts_with "gradle", :because => "Differing version of same formula"

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end

  test do
    ENV["GRADLE_USER_HOME"] = testpath
    assert_match "Gradle #{version}", shell_output("#{bin}/gradle --version")
  end
end
