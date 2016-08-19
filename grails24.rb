class Grails24 < Formula
  desc "Web application framework for the Groovy language"
  homepage "http://grails.org"
  url "https://github.com/grails/grails-core/releases/download/v2.4.5/grails-2.4.5.zip"
  sha256 "3faa1631b98d8e2bb145eb9aac1c9bf4c339064452409ddd2b96bdae29a7cf7f"

  bottle :unneeded

  depends_on :java

  conflicts_with "grails", :because => "Differing versions of the same formula"

  def install
    rm_f Dir["bin/*.bat", "bin/cygrails", "*.bat"]
    prefix.install %w[LICENSE README]
    libexec.install Dir["*"]
    bin.mkpath
    Dir["#{libexec}/bin/*"].each do |f|
      next unless File.extname(f).empty?
      ln_s f, bin+File.basename(f)
    end
  end

  test do
    ENV["JAVA_HOME"] = `/usr/libexec/java_home`.chomp
    assert_match "Grails version: #{version}",
      shell_output("#{bin}/grails --version")
  end
end
