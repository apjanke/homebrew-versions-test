class Virtuoso616 < Formula
  desc "High-performance object-relational SQL database"
  homepage "http://virtuoso.openlinksw.com/wiki/main/"
  url "https://downloads.sourceforge.net/project/virtuoso/virtuoso/6.1.6/virtuoso-opensource-6.1.6.tar.gz"
  sha256 "c6bfa6817b3dad5f87577b68f4cf554d1bfbff48178a734084ac3dcbcea5a037"

  bottle do
    sha256 "a4d6211240c5c63acfa138dfee3b9ec3af59fe6b72f71d8ee3c2a309a5c0fe16" => :yosemite
    sha256 "ae32083a6b88ca8f2c62a41d6365455723118180920d6b5924db73452dc81519" => :mavericks
    sha256 "e912f51ff038a85144f9939bd43fbbaf7cc653fd8e12a18ff8774e5cc1e3542b" => :mountain_lion
  end

  head do
    url "https://github.com/openlink/virtuoso-opensource.git", :branch => "develop/6"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  # If gawk isn't found, make fails deep into the process.
  depends_on "gawk" => :build
  depends_on "openssl"

  conflicts_with "unixodbc", :because => "Both install `isql` binaries."

  skip_clean :la

  def install
    ENV.m64 if MacOS.prefer_64_bit?
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    NOTE: the Virtuoso server will start up several times on port 1111
    during the install process.
    EOS
  end

  test do
    "[[ $(#{bin}/virtuoso-t --help) != *6.1.6* ]]"
  end
end
