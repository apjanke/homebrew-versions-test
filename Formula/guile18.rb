class Guile18 < Formula
  homepage "https://www.gnu.org/software/guile/"
  url "https://ftpmirror.gnu.org/guile/guile-1.8.8.tar.gz"
  mirror "https://ftp.gnu.org/gnu/guile/guile-1.8.8.tar.gz"
  sha256 "c3471fed2e72e5b04ad133bbaaf16369e8360283679bcf19800bc1b381024050"

  depends_on "pkg-config" => :build
  depends_on "libtool" => :run
  depends_on "libffi"
  depends_on "libunistring"
  depends_on "bdw-gc"
  depends_on "gmp"
  depends_on "readline"

  fails_with :llvm do
    build 2336
    cause "Segfaults during compilation"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-libreadline-prefix=#{Formula["readline"].opt_prefix}"
    system "make", "install"

    # A really messed up workaround required on OS X --mkhl
    Pathname.glob("#{lib}/*.dylib") do |dylib|
      lib.install_symlink dylib.basename => "#{dylib.basename(".dylib")}.so"
    end
  end

  test do
    hello = testpath/"hello.scm"
    hello.write <<-EOS.undent
      (display "Hello World")
      (newline)
    EOS

    ENV["GUILE_AUTO_COMPILE"] = "0"

    system bin/"guile", hello
  end
end
