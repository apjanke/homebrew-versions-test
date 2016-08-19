class JbossForge1 < Formula
  desc "Tools to help set up and configure a project"
  homepage "http://forge.jboss.org/"
  url "https://repository.jboss.org/nexus/service/local/artifact/maven/redirect?r=releases&g=org.jboss.forge&a=forge-distribution&v=1.4.4.Final&e=zip"
  version "1.4.4.Final"
  sha256 "fb794032f769ec27a7f8cc28da72cfc4a2e349f7c4836ec15f5fa567d3af9892"

  bottle :unneeded

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[bin modules jboss-modules.jar]
    bin.install_symlink libexec/"bin/forge"
  end
end
