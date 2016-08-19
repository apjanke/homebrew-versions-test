class Autoconf264 < Formula
  desc "Automatic configure script builder"
  homepage "https://www.gnu.org/software/autoconf/"
  url "https://ftpmirror.gnu.org/autoconf/autoconf-2.64.tar.gz"
  mirror "https://ftp.gnu.org/gnu/autoconf/autoconf-2.64.tar.gz"
  sha256 "a84471733f86ac2c1240a6d28b705b05a6b79c3cca8835c3712efbdf813c5eb6"

  bottle do
    sha256 "445f91433235efd87983ce0f266cf4e6399860b2d4e233507151d540454730b2" => :yosemite
    sha256 "78da335244abe71dc42cf5d131818e3419895ab24591f0861af998e1c2dd355a" => :mavericks
    sha256 "bbe82576b19bfce25e975a7d6005adc6b6ed7d45f97e80f2c36537064be4221c" => :mountain_lion
  end

  def install
    system "./configure", "--program-suffix=264",
                          "--prefix=#{prefix}",
                          "--datadir=#{share}/autoconf264"
    system "make", "install"
  end
end
