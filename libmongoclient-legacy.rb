class LibmongoclientLegacy < Formula
  homepage "https://www.mongodb.org"
  url "https://github.com/mongodb/mongo-cxx-driver/archive/legacy-1.1.1.tar.gz"
  sha256 "c48c80b019aa2f439982943d3fc94547d8c7760194528f81f3cb1965fc7eb6e6"

  head "https://github.com/mongodb/mongo-cxx-driver.git", :branch => "legacy"

  bottle do
    sha256 "11a511e574f2de1be11345e850f8a48d34a3fa7af1e49413219b050eb9cfb033" => :el_capitan
    sha256 "874d3c287a5b399a156fd6d1e3b133a5f82231562714a44ad706c2ea1511026f" => :yosemite
    sha256 "984a9b24c5f6e6b8e8a7b83fca80f128e5168705b9064081e39a7bf5f8b9fa0c" => :mavericks
  end

  conflicts_with "libmongoclient", :because => "libmongoclient contains 26compat branch"

  option :cxx11

  depends_on "scons" => :build

  if build.cxx11?
    depends_on "boost" => "c++11"
  else
    depends_on "boost"
  end

  def install
    ENV.cxx11 if build.cxx11?

    boost = Formula["boost"].opt_prefix

    args = [
      "--prefix=#{prefix}",
      "-j#{ENV.make_jobs}",
      "--cc=#{ENV.cc}",
      "--cxx=#{ENV.cxx}",
      "--extrapath=#{boost}",
      "--sharedclient",
      # --osx-version-min is required to override --osx-version-min=10.6 added
      # by SConstruct which causes "invalid deployment target for -stdlib=libc++"
      # when using libc++
      "--osx-version-min=#{MacOS.version}",
      "install",
    ]

    args << "--libc++" if MacOS.version >= :mavericks

    scons *args
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <mongo/client/dbclient.h>

      int main() {
          mongo::DBClientConnection c;
          mongo::client::initialize();
          return 0;
      }
    EOS
    system ENV.cxx, "-L#{lib}", "-lmongoclient",
           "-L#{Formula["boost"].opt_lib}", "-lboost_system",
           testpath/"test.cpp", "-o", testpath/"test"
    system "./test"
  end
end
