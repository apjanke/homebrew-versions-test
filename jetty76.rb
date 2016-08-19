class Jetty76 < Formula
  desc "Java servlet engine and webserver"
  homepage "https://www.eclipse.org/jetty/"
  url "http://download.eclipse.org/jetty/7.6.17.v20150415/dist/jetty-distribution-7.6.17.v20150415.tar.gz"
  version "7.6.17.v20150415"
  sha256 "57d6bbb48771944b8c2a3124240c0c4a78284a75db2b86018f543654dfd50eef"

  bottle do
    cellar :any
    sha256 "b00c93abc2a48dbac36169b595fc281eb0c9e66a99f9218c00e63bd132393423" => :yosemite
    sha256 "47a9172532ffa40dc1495bc180c016d996b5dcddfa90411fb0cb3e59f9776267" => :mavericks
    sha256 "d1036c8ad02f4b7c40abecf247e5fbbd9764a6c577f1033642eaacec8156c31f" => :mountain_lion
  end

  conflicts_with "jetty", :because => "Differing version of same formula"

  def install
    rm_rf Dir["bin/*.{cmd,bat]}"]

    libexec.install Dir["*"]
    (libexec+"logs").mkpath

    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each do |f|
      scriptname = File.basename(f, ".sh")
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        JETTY_HOME=#{libexec}
        #{f} $@
      EOS
      chmod 0755, bin+scriptname
    end
  end
end
