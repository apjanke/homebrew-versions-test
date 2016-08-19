class Openjpeg20 < Formula
  desc "Library for JPEG-2000 image manipulation"
  homepage "http://www.openjpeg.org/"
  url "https://downloads.sourceforge.net/project/openjpeg.mirror/2.0.0/openjpeg-2.0.0.tar.gz"
  sha256 "334df538051555381ee3bbbe3a804c9c028a021401ba2960d6f35da66bf605d8"

  bottle do
    cellar :any
    sha256 "652310a4988b49222c45044a009ee80a0547dc93990716d873653b3df9733b44" => :yosemite
    sha256 "d6949baa3668572dd71d6df15ac1069ee06edd3b2d8fcae255dab7d6d2f7ac2d" => :mavericks
    sha256 "6107f415632764c191c84eb393460a2e82f3d27134d8e426291552ea619551af" => :mountain_lion
  end

  depends_on "cmake" => :build
  depends_on "little-cms2"
  depends_on "libtiff"
  depends_on "libpng"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
