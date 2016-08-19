class Autoconf213 < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf/"
  url "https://ftpmirror.gnu.org/autoconf/autoconf-2.13.tar.gz"
  mirror "https://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz"
  sha256 "f0611136bee505811e9ca11ca7ac188ef5323a8e2ef19cffd3edb3cf08fd791e"

  bottle do
    cellar :any
    sha256 "aaca2ae48a63679a6ae88c537dd6b79500efac75389fd566afd6f108471f35a8" => :yosemite
    sha256 "7fab563545c3f6ae3b85dbfceaff1321191efba3d2d6d41da4aa71866eabad89" => :mavericks
    sha256 "8c244a8ed8a78ff3e6ed881cb9958eed27beee468647c6402f9bb74c434f6d32" => :mountain_lion
  end

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--program-suffix=213",
                          "--prefix=#{prefix}",
                          "--infodir=#{info}",
                          "--datadir=#{share}/autoconf213"
    system "make", "install"
  end
end
