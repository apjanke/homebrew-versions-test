class Valgrind38 < Formula
  desc "Dynamic analysis tools"
  homepage "http://www.valgrind.org/"
  url "http://valgrind.org/downloads/valgrind-3.8.1.tar.bz2"
  sha256 "473be00576bed311a662b277a2bfbe97d9cca4058e68619a0e420c9fc19958db"

  bottle do
    sha256 "0dcc7f6f685a66c2fb66f4dc9ecb716a7cf5bab1bc6a63bf16f2f7f0c2c0513a" => :mountain_lion
  end

  depends_on :macos => :snow_leopard
  depends_on MaximumMacOSRequirement => :mountain_lion

  env :std if :macos == :snow_leopard

  conflicts_with "valgrind", :because => "Differing version of same formula"

  # Valgrind needs vcpreload_core-*-darwin.so to have execute permissions.
  # See #2150 for more information.
  skip_clean "lib/valgrind"

  # 1: For Xcode-only systems, we have to patch hard-coded paths, use xcrun &
  #    add missing CFLAGS. See: https://bugs.kde.org/show_bug.cgi?id=295084
  # 2: Fix for 10.7.4 w/XCode-4.5, duplicate symbols. Reported upstream in
  #    https://bugs.kde.org/show_bug.cgi?id=307415
  patch do
    url "https://gist.githubusercontent.com/2bits/3784836/raw/f046191e72445a2fc8491cb6aeeabe84517687d9/patch1.diff"
    sha256 "1e50a732c695303ca2edab4d423c4c3ff77d54cf64d358bac65297491a587731"
  end

  if MacOS.version == :lion
    patch do
      url "https://gist.githubusercontent.com/2bits/3784930/raw/dc8473c0ac5274f6b7d2eb23ce53d16bd0e2993a/patch2.diff"
      sha256 "b381b5f5bfc544214c2d88d49066ed806596838375a9b2397abe588aaa6c2ed0"
    end
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    if MacOS.prefer_64_bit?
      args << "--enable-only64bit" << "--build=amd64-darwin"
    else
      args << "--enable-only32bit"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    system "#{bin}/valgrind", "ls", "-l"
  end
end
