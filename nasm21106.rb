class Nasm21106 < Formula
  desc "Nasm 2.11.06 Formula"
  homepage "http://www.nasm.us/"
  url "http://www.nasm.us/pub/nasm/releasebuilds/2.11.06/nasm-2.11.06.tar.xz"
  sha256 "90f60d95a15b8a54bf34d87b9be53da89ee3d6213ea739fb2305846f4585868a"

  bottle do
    cellar :any
    sha256 "bd94c4827a3fbc20d9e2534414f7879f41b6d886b260ee2d0494f0fc9af1ffcb" => :yosemite
    sha256 "f8c7f1bfacddb71283e41054461063295bdcb2f16f2bdaa3eba9958993ff5bc8" => :mavericks
    sha256 "f848949bb46ff121bc33937f1de53d8dd6fe8a4c46e8888104181a6966f7e62f" => :mountain_lion
  end

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make", "install", "install_rdf"
  end

  test do
    (testpath/"foo.s").write <<-EOS
      mov eax, 0
      mov ebx, 0
      int 0x80
    EOS

    system "#{bin}/nasm", "foo.s"
    code = File.open("foo", "rb") { |f| f.read.unpack("C*") }
    expected = [0x66, 0xb8, 0x00, 0x00, 0x00, 0x00, 0x66, 0xbb,
                0x00, 0x00, 0x00, 0x00, 0xcd, 0x80]
    assert_equal expected, code
  end
end
