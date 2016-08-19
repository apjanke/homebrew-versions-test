class Saxon6 < Formula
  desc "XSLT 1.0 processor"
  homepage "http://saxon.sourceforge.net/saxon6.5.5/"
  url "https://downloads.sourceforge.net/project/saxon/saxon6/6.5.5/saxon6-5-5.zip"
  mirror "https://de.osdn.jp/projects/sfnet_saxon/downloads/saxon6/6.5.5/saxon6-5-5.zip/"
  version "6.5.5"
  sha256 "a76806dda554edc844601d0ec0fb3d2a10a2f397eabf3569dfb44b628363afc4"

  def install
    libexec.install Dir["*.jar", "doc", "samples"]
    bin.write_jar_script libexec/"saxon.jar", "saxon6"
  end

  test do
    (testpath/"test.xml").write <<-XML.undent
      <test>It works!</test>
    XML
    (testpath/"test.xsl").write <<-XSL.undent
      <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
        <xsl:template match="/">
          <html>
            <body>
              <p><xsl:value-of select="test"/></p>
            </body>
          </html>
        </xsl:template>
      </xsl:stylesheet>
    XSL
    assert_equal <<-HTML.undent.chop, shell_output("#{bin}/saxon6 test.xml test.xsl")
      <html>
         <body>
            <p>It works!</p>
         </body>
      </html>
    HTML
  end
end
