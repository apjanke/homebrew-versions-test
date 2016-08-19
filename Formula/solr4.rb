class Solr4 < Formula
  desc "Enterprise search platform from Apache Lucene project"
  homepage "https://lucene.apache.org/solr/"
  url "https://archive.apache.org/dist/lucene/solr/4.10.4/solr-4.10.4.tgz"
  sha256 "ac3543880f1b591bcaa962d7508b528d7b42e2b5548386197940b704629ae851"

  depends_on :java

  conflicts_with "solr", :because => "Differing versions of same formula"

  skip_clean "example/logs"

  def install
    libexec.install Dir["*"]
    inreplace "#{libexec}/bin/solr", "solr.in.sh", "solr4.in.sh"
    bin.install "#{libexec}/bin/solr" => "solr4"
    share.install "#{libexec}/bin/solr.in.sh" => "solr4.in.sh"
    prefix.install "#{libexec}/example"
  end

  plist_options :manual => "solr4 start"

  def plist; <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/solr4</string>
            <string>start</string>
            <string>-f</string>
          </array>
          <key>ServiceDescription</key>
          <string>#{name}</string>
          <key>WorkingDirectory</key>
          <string>#{HOMEBREW_PREFIX}</string>
          <key>RunAtLoad</key>
          <true/>
      </dict>
      </plist>
    EOS
  end

  test do
    system "solr4"
  end
end
