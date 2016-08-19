class Sonar4 < Formula
  desc "Manage code quality"
  homepage "http://www.sonarqube.org/"
  url "http://dist.sonar.codehaus.org/sonarqube-4.5.4.zip"
  sha256 "c72f833d290da237e967a34d6ed03d7f33c97ec90f4c0b77209dfd8a3100ae44"

  bottle do
    sha256 "c3a82451cb70a5411fc7c617d468637286ba21920de10ebe8a72e1ecdee329dd" => :yosemite
    sha256 "48d0c098e215a2ef51c66ac3dcaad608edde67d83ee4d625b49f96112e42fb85" => :mavericks
    sha256 "3263ac8ab0dbaa64f42bf9638cbae51b5bc30ecfb724111f8351498b951f9b68" => :mountain_lion
  end

  def install
    # Delete native bin directories for other systems
    rm_rf Dir["bin/{aix,hpux,linux,solaris,windows}-*"]

    if MacOS.prefer_64_bit?
      rm_rf "bin/macosx-universal-32"
    else
      rm_rf "bin/macosx-universal-64"
    end

    # Delete Windows files
    rm_f Dir["war/*.bat"]
    libexec.install Dir["*"]

    if MacOS.prefer_64_bit?
      bin.install_symlink "#{libexec}/bin/macosx-universal-64/sonar.sh" => "sonar"
    else
      bin.install_symlink "#{libexec}/bin/macosx-universal-32/sonar.sh" => "sonar"
    end
  end

  plist_options :manual => "sonar console"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
        <string>#{opt_bin}/sonar</string>
        <string>start</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    assert_match "SonarQube", pipe_output("#{bin}/sonar status")
  end
end
