class Libxc21 < Formula
  desc "Library of exchange and correlation functionals"
  homepage "http://www.tddft.org/programs/octopus/wiki/index.php/Libxc"
  url "http://www.tddft.org/programs/octopus/down.php?file=libxc/libxc-2.1.0.tar.gz"
  sha256 "481fcd811d7f5e99ceab2596be09e422a21e9b03437ca607b9c03ffc42050d29"

  bottle do
    cellar :any
    sha256 "5fa1514e1877a5381a177275dab3834d533971bb4413aca9dc78bc65a507e815" => :yosemite
    sha256 "a480ad2a7d1b77aab3469fb70784984ab27266a96bdef642cb4163158eaef573" => :mavericks
    sha256 "dd79b4beaa7d09ff761a65f83dac94aac11ac6640cd055b4152dd58f359a766e" => :mountain_lion
  end

  depends_on :fortran

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--enable-shared",
                          "FCCPP=#{ENV.fc} -E -x c",
                          "CC=#{ENV.cc}",
                          "CFLAGS=-pipe"
    ENV.deparallelize # Should get rid of the race condition
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <stdio.h>
      #include <xc.h>
      int main()
      {
        int i, vmajor, vminor, func_id = 1;
        xc_version(&vmajor, &vminor);
        printf(\"%d.%d\", vmajor, vminor);
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lxc", "-I#{include}", "-o", "ctest"
    system "./ctest"

    (testpath/"test.f90").write <<-EOS.undent
      program lxctest
        use xc_f90_types_m
        use xc_f90_lib_m
      end program lxctest
    EOS
    ENV.fortran
    system ENV.fc, "test.f90", "-L#{lib}", "-lxc", "-I#{include}", "-o", "ftest"
    system "./ftest"
  end
end
