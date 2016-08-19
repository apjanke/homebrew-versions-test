class Antlr2 < Formula
  desc "ANother Tool for Language Recognition"
  homepage "http://www.antlr2.org"
  url "http://www.antlr2.org/download/antlr-2.7.7.tar.gz"
  sha256 "853aeb021aef7586bda29e74a6b03006bcb565a755c86b66032d8ec31b67dbb9"

  bottle do
    sha256 "7dcc3717cb1fd192ddb3200378856b81d1ccfaeeabcb60817e6927a4c78111a9" => :yosemite
    sha256 "f70c59f788573514d6666fc20410456b584e328108af814d17422121b17278d6" => :mavericks
    sha256 "2d722d988a3352dae7b13d6344af7bf34a0301d39bd7d8b0da5e2f285a4af008" => :mountain_lion
  end

  def install
    # C Sharp is explicitly disabled because the antlr configure script will
    # confuse the Chicken Scheme compiler, csc, for a C sharp compiler.
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-csharp"
    system "make"

    libexec.install "antlr.jar"
    include.install "lib/cpp/antlr"
    lib.install "lib/cpp/src/libantlr.a"

    (bin/"antlr2").write <<-EOS.undent
      #!/bin/sh
      java -classpath #{libexec}/antlr.jar antlr.Tool "$@"
    EOS
  end
end
