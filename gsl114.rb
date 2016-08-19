class Gsl114 < Formula
  desc "Numerical library for C and C++"
  homepage "https://www.gnu.org/software/gsl/"
  url "https://ftpmirror.gnu.org/gsl/gsl-1.14.tar.gz"
  mirror "https://ftp.gnu.org/gnu/gsl/gsl-1.14.tar.gz"
  sha256 "3d4a47afd9a1e7c73b97791b4180d8cc4d5f0e5db6027fe06437f1f3f957fafb"

  bottle do
    cellar :any
    sha256 "e3e5dcf0d83043554296bc8dc836dcd04c496b8417bd004adab5420dc8c212b5" => :yosemite
    sha256 "5efe0db286ac52fdd72976264d1bdf1852d3d5ae6a6971a0297edc7c2f724e75" => :mavericks
    sha256 "11f5aff7fdbc03258801ae76373ba5d7420f24e1beca93de7435464df0578b19" => :mountain_lion
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make" # "make" and "make install" *must* be done separately
    system "make", "install"
  end

  test do
    system bin/"gsl-config", "--prefix", "--cflags", "--version"
  end
end
