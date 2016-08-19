class Leptonica169 < Formula
  desc "Image processing and image analysis library"
  homepage "http://www.leptonica.org/"
  url "http://www.leptonica.org/source/leptonica-1.69.tar.gz"
  sha256 "3eb7669dcda7e417f399bb3698414ea523270797dfd36c59b08ef37a3fe0a72d"

  bottle do
    cellar :any
    sha256 "bae61b3605c495b109678205a0971dc0c30549eb9ef26ba7116899bda42bf600" => :yosemite
    sha256 "8dfdecd0322a25042c41515ea1f389294659f70dc9ad1934cd50a7216b1e50af" => :mavericks
    sha256 "ee43fb63343c1e9d114f81c3a402d749b4fa129fe9f1314c08386af8522ff960" => :mountain_lion
  end

  depends_on "libpng" => :recommended
  depends_on "jpeg" => :recommended
  depends_on "libtiff" => :optional

  conflicts_with "osxutils",
    :because => "both leptonica and osxutils ship a `fileinfo` executable."
  conflicts_with "leptonica",
    :because => "Differing versions of the same formula."

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/yuvtest"
  end
end
