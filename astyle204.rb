class Astyle204 < Formula
  desc "Source code indenter, formatter, and beautifier."
  homepage "http://astyle.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/astyle/astyle/astyle%202.04/astyle_2.04_macosx.tar.gz"
  sha256 "e0ba90723463172fd8a063897092284993eeebb87c63cf26ee36f555b0d89368"

  bottle do
    cellar :any
    sha256 "e7a38bf55b8cce4d0f2c1ac3a69b83670c2809e800d45ecf825f78c3c329e233" => :yosemite
    sha256 "11f398760d41131a866bd23b6de721e6518e0c86c54fb867eb28ed95b508addc" => :mavericks
    sha256 "98fbe0b2ecc638bc09894bf6def96e9bcab59a501e1373582b8df5435cd7b188" => :mountain_lion
  end

  conflicts_with "astyle", :because => "Differing versions of same formulae"

  def install
    cd "src" do
      system "make", "CXX=#{ENV.cxx}", "-f", "../build/mac/Makefile"
      bin.install "bin/astyle"
    end
  end

  test do
    (testpath/"test.c").write("int main(){return 0;}\n")
    system "#{bin}/astyle", "--style=gnu", "--indent=spaces=4",
           "--lineend=linux", "#{testpath}/test.c"
    assert_equal File.read("test.c"), <<-EOS.undent
      int main()
      {
          return 0;
      }
    EOS
  end
end
