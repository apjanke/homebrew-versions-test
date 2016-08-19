class Libidn2 < Formula
  desc "Internationalized domain name library for IDNA2008"
  homepage "https://www.gnu.org/software/libidn/"
  url "http://alpha.gnu.org/gnu/libidn/libidn2-0.10.tar.gz"
  sha256 "3d301890bdbb137424f5ea495f82730a4b85b6a2549e47de3a34afebeac3e0e3"

  bottle do
    cellar :any
    sha256 "d25ba971f164b3345fa0d9fcce5b8f0b59a8ae4348a3570f296410305f253ef6" => :el_capitan
    sha256 "730dd356547fe41ea848335319608ad75ff98ae59f1550676cb86011723b57af" => :yosemite
    sha256 "49b9882fe6971e1623b8f64debfe6234e798b81424b4aac076b393d0e8cca07e" => :mavericks
  end

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    ENV["CHARSET"] = "UTF-8"
    system "#{bin}/idn2", "räksmörgås.se", "blåbærgrød.no"
  end
end
