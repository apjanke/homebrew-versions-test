class Automake112 < Formula
  homepage "https://www.gnu.org/software/automake/"
  url "https://ftpmirror.gnu.org/automake/automake-1.12.6.tar.gz"
  mirror "https://ftp.gnu.org/gnu/automake/automake-1.12.6.tar.gz"
  sha256 "0cbe570db487908e70af7119da85ba04f7e28656b26f717df0265ae08defd9ef"

  bottle do
    sha256 "4a4b4d826397fc25ead3d15df1a9b6b5caa2f6b209db8d0fed649e6daa42646a" => :yosemite
    sha256 "6916c128cdfadb43ddec3efbf354f2c222be50f7256f9c98c395ef69aadaa300" => :mavericks
    sha256 "41def9cad836873c8a227da2995d43f8ca877ac42da218b83c498c5b3a751935" => :mountain_lion
  end

  depends_on "autoconf" => :run

  keg_only :provided_until_xcode43

  def install
    system "./configure", "--prefix=#{prefix}", "--program-suffix=112"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/mxcl/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<-EOS.undent
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    system bin/"automake112", "--version"
  end
end
