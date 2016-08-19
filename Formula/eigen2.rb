class Eigen2 < Formula
  desc "C++ template library for linear algebra"
  homepage "http://eigen.tuxfamily.org/"
  url "https://bitbucket.org/eigen/eigen/get/2.0.17.tar.bz2"
  sha256 "7255e856ed367ce6e6e2d4153b0e4e753c8b8d36918bf440dd34ad56aff09960"

  bottle do
    cellar :any
    sha256 "59cbfaafbcba0535357bb63ac0e4877d47c2a52869cd32b7d6af74b5521d81bd" => :yosemite
    sha256 "38c28e3bc3a78717584ecc83fabeeb840884273301c10311c7c274517ce75a6a" => :mavericks
    sha256 "b400f68bd0c66a8616526334732eb7106070135af5fc7f6b347810f4dfbf785b" => :mountain_lion
  end

  depends_on "cmake" => :build

  def install
    mkdir "eigen-build" do
      args = std_cmake_args
      args << "-DCMAKE_BUILD_TYPE=Release"
      args << "-Dpkg_config_libdir='#{lib}'" << ".."

      system "cmake", *args
      system "make", "install"
    end
  end
end
