class Isl012 < Formula
  desc "Integer Set Library for the polyhedral model"
  homepage "http://isl.gforge.inria.fr/"
  # Track gcc infrastructure releases.
  url "http://isl.gforge.inria.fr/isl-0.12.2.tar.bz2"
  mirror "ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.12.2.tar.bz2"
  sha256 "f4b3dbee9712850006e44f0db2103441ab3d13b406f77996d1df19ee89d11fb4"

  bottle do
    cellar :any
    sha256 "e043247dc75edb9579104e307039da57e6c1f0945567450224282604251b7235" => :yosemite
    sha256 "83301cbde866fb443dabf5836a74f8d568a14347d8db1c97aca3c0894db9bbef" => :mavericks
    sha256 "aa455b386914a1fd3ef15982cff46404eca9b9ce540e913a68d427d49f82085e" => :mountain_lion
  end

  keg_only "Conflicts with isl in main repository."

  depends_on "gmp4"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
    system "make"
    system "make", "install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <isl/ctx.h>

      int main()
      {
        isl_ctx* ctx = isl_ctx_alloc();
        isl_ctx_free(ctx);
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-I#{Formula["gmp4"].opt_include}", "-L#{lib}", "-lisl", "-o", "test"
    system "./test"
  end
end
