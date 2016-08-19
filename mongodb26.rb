class Mongodb26 < Formula
  desc "High-performance document-oriented database"
  homepage "https://www.mongodb.org/"
  url "https://fastdl.mongodb.org/src/mongodb-src-r2.6.11.tar.gz"
  sha256 "e1a64a1ef7114f3e8ed3c7acaa4e97ffe30e2b57a1a5f2a40f0018bad3b8d12f"

  bottle do
    cellar :any_skip_relocation
    sha256 "3865092c0e9c4e646953b3267d9245157d0e029a4929323e5ff2d101896ec0a9" => :el_capitan
    sha256 "560373b6a3286f56609aaf810e4fb48db488ecf55a14913815892badf59e7dde" => :yosemite
    sha256 "3839484db705021580b81f5b24dbc43b75e97dc39a11fb1edb9916a39a871f27" => :mavericks
  end

  option "with-boost", "Compile using installed boost, not the version shipped with mongodb"

  depends_on :macos => :snow_leopard
  depends_on "scons" => :build
  depends_on "boost" => :optional
  depends_on "openssl" => :optional

  # Review this patch with each release.
  # This modifies the SConstruct file to include 10.10 and 10.11 as accepted build options.
  if MacOS.version >= :yosemite
    patch do
      url "https://gist.githubusercontent.com/asmarques/4e4e66121dbe46a08933/raw/d6753551ff3849bf0fb5ca87c0a96e1255f4254d/mongodb26-elcapitan.diff"
      sha256 "2f79588a8a15660908d8d071655541c9ab0ac425550b02dc454c861c75f86606"
    end
  end

  def install
    args = %W[
      --prefix=#{prefix}
      -j#{ENV.make_jobs}
      --cc=#{ENV.cc}
      --cxx=#{ENV.cxx}
      --osx-version-min=#{MacOS.version}
      --full
    ]

    args << "--use-system-boost" if build.with? "boost"
    args << "--64" if MacOS.prefer_64_bit?

    # Pass the --disable-warnings-as-errors flag to Scons when on Yosemite
    # or later, otherwise 2.6.x won't build from source due to a Clang 3.5+
    # error - https://github.com/mongodb/mongo/pull/956#issuecomment-94545753
    args << "--disable-warnings-as-errors" if MacOS.version >= :yosemite

    if build.with? "openssl"
      args << "--ssl" << "--extrapath=#{Formula["openssl"].opt_prefix}"
    end

    scons "install", *args

    (buildpath+"mongod.conf").write mongodb_conf
    etc.install "mongod.conf"

    (var/"mongodb").mkpath
    (var/"log/mongodb").mkpath
  end

  def mongodb_conf; <<-EOS.undent
    systemLog:
      destination: file
      path: #{var}/log/mongodb/mongo.log
      logAppend: true
    storage:
      dbPath: #{var}/mongodb
    net:
      bindIp: 127.0.0.1
    EOS
  end

  plist_options :manual => "mongod --config #{HOMEBREW_PREFIX}/etc/mongod.conf"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/mongod</string>
        <string>--config</string>
        <string>#{etc}/mongod.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>StandardOutPath</key>
      <string>#{var}/log/mongodb/output.log</string>
      <key>HardResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
      <key>SoftResourceLimits</key>
      <dict>
        <key>NumberOfFiles</key>
        <integer>1024</integer>
      </dict>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/mongod", "--sysinfo"
  end
end
