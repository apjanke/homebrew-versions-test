class Libuv0 < Formula
  desc "Multi-platform library with a focus on async I/O"
  homepage "https://github.com/libuv/libuv"
  url "https://github.com/libuv/libuv/archive/v0.10.36.tar.gz"
  sha256 "421087044cab642f038c190f180d96d6a1157be89adb4630881930495b8f5228"
  head "https://github.com/libuv/libuv.git", :branch => "v0.10"

  bottle do
    cellar :any
    sha256 "e7a173640b0f90da34df18c251169d34ee30b178079c3955affc0efe5bc72366" => :yosemite
    sha256 "842d80e7f5b74339cc0d7bda1019265c87dcb30b9a939cac7fbf6794df9a0726" => :mavericks
    sha256 "5069cef8166c12abc3cf4a730f9d37d3d3b33949844dd11b9e8a62e4aeae19ca" => :mountain_lion
  end

  conflicts_with "libuv"

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "make", "libuv.dylib"
    prefix.install "include"
    lib.install "libuv.dylib"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <uv.h>

      int main()
      {
        uv_loop_t* loop = uv_loop_new();
        uv_loop_delete(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-luv", "-o", "test"
    system "./test"
  end
end
