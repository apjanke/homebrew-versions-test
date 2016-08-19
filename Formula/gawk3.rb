class Gawk3 < Formula
  desc "GNU awk utility"
  homepage "https://www.gnu.org/software/gawk/"
  url "https://ftpmirror.gnu.org/gawk/gawk-3.1.8.tar.bz2"
  mirror "https://ftp.gnu.org/gnu/gawk/gawk-3.1.8.tar.bz2"
  sha256 "5dbc7b2c4c328711337c2aacd09a122c7313122262e3ff034590f014067412b4"

  bottle do
    sha256 "1759758515e164e132faca481366230aadf1b23bd4beec9fbdb5e75046d6bdeb" => :yosemite
    sha256 "69de726a50262eb82938332505f0f55b3112423212b4a2a372b1e30a90b34eef" => :mavericks
    sha256 "88861130d66e15afafc9627fb065ab4b7b45e599bb02dd50c67aa2592da67cd0" => :mountain_lion
  end

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make"
    system "make", "install"
  end

  test do
    output = pipe_output("#{bin}/gawk '{ gsub(/Macro/, \"Home\"); print }' -", "Macrobrew")
    assert_equal "Homebrew", output.strip
  end
end
