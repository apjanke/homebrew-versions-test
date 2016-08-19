class Arangodb2 < Formula
  desc "The Multi-Model NoSQL Database (Version 2)."
  homepage "https://www.arangodb.com/"
  url "https://www.arangodb.com/repositories/Source/ArangoDB-2.8.11.tar.gz"
  sha256 "1379871bc4209d0c9c3243e1ac6072bd8f3d541c488089ed29c8b285ebacd1e1"

  bottle do
    sha256 "63855f4e73dfb190fa0853e2f0f94bf7773660e6d328dac55663d922bae75ce7" => :el_capitan
    sha256 "dea8e983e16c7bd814feff1e6d4b66880c8bd491c3e7c0f39678774fa28cc900" => :yosemite
    sha256 "da10623adf5c65ea1306ac827163d2644b37da3baa60d24be711a0a03c9ab5ae" => :mavericks
  end

  conflicts_with "arangodb", :because => "Differing versions of the same formula"

  depends_on "gcc" if MacOS.version == :mavericks
  depends_on "go" => :build
  depends_on "openssl"

  needs :cxx11

  fails_with :clang do
    build 600
    cause "Fails with compile errors"
  end

  def install
    ENV.libcxx

    # clang on 10.8 will still try to build against libstdc++,
    # which fails because it doesn't have the C++0x features
    # arangodb requires.
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-relative
      --datadir=#{share}
      --localstatedir=#{var}
      --program-suffix=-2.8
    ]

    system "./configure", *args
    system "make", "install"
  end

  def post_install
    (var/"lib/arangodb").mkpath
    (var/"log/arangodb").mkpath

    system "#{sbin}/arangod-2.8", "--upgrade"
  end

  def caveats
    s = <<-EOS.undent
      Please note that clang and/or its standard library 7.0.0 has a severe
      performance issue. Please consider using '--cc=gcc-5' when installing
      if you are running on such a system.
    EOS

    s
  end

  plist_options :manual => "#{HOMEBREW_PREFIX}/opt/arangodb2/sbin/arangod-2.8"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_sbin}/arangod-2.8</string>
          <string>-c</string>
          <string>#{etc}/arangodb/arangod-2.8.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  test do
    assert_equal "it works!\n", shell_output("#{bin}/arangosh-2.8 --javascript.execute-string \"require('@arangodb').print('it works!')\"")
  end
end
