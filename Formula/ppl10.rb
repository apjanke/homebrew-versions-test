class Ppl10 < Formula
  homepage "http://bugseng.com/products/ppl/"
  url "http://bugseng.com/products/ppl/download/ftp/releases/1.0/ppl-1.0.tar.gz"
  sha256 "fd346687482ad51c1e98eb260bd61dd5a35a0cff5f580404380c88b0089a71b4"

  bottle do
    sha256 "12126de7c884e43d2c2dc4a334266ee950fd71abafcfee24c542c7213cb81966" => :yosemite
    sha256 "275df32f51620777164a1ee3a85316b72a884a4326c099a72951531646995b5e" => :mavericks
    sha256 "a08ca71a5cb5d3067807303e9ddbe11af4ee80ff16df0737139c13e62cd6a364" => :mountain_lion
  end

  depends_on "homebrew/dupes/m4" => :build if MacOS.version < :leopard
  depends_on "gmp4"

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-ppl_lpsol",
                          "--disable-ppl_lcdd",
                          "--disable-ppl_pips",
                          "--with-gmp=#{Formula["gmp4"].opt_prefix}"
    system "make", "install"
  end

  test do
    system bin/"ppl-config", "--bindir", "--libdir", "--license"
  end
end
