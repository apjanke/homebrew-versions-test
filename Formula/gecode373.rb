class Gecode373 < Formula
  homepage "http://www.gecode.org/"
  url "http://www.gecode.org/download/gecode-3.7.3.tar.gz"
  sha256 "e7cc8bcc18b49195fef0544061bdd2e484a1240923e4e85fa39e8d6bb492854c"

  bottle do
    cellar :any
    sha256 "dac2c21c58fb4a4f1db2d04400f2c5f4459e7e2acc03cc647bf1f97f4ea35cff" => :yosemite
    sha256 "662e1e834400151e543367376cf61e120e3074bb8b4c5843c7f036dc8678f66b" => :mavericks
    sha256 "1d3231a95474508a060351b52cf2b8b51894a726c820b7597716aad5f9be39c1" => :mountain_lion
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-examples"
    system "make", "install"
  end

  test do
    system "#{bin}/fz", "-help"
  end
end
