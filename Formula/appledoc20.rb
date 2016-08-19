# The 2.1 series requires Lion or newer.
# 2.0.6 is provided for Snow Leopard compatibility.
class Appledoc20 < Formula
  desc "Objective-C API documentation generator"
  homepage "http://appledoc.gentlebytes.com/"
  url "https://github.com/tomaz/appledoc/archive/v2.0.6.tar.gz"
  sha256 "f62bed39a0e65eab4035ea82784e7a9347b3bfc7c424e6e855b8ff698628cc21"

  depends_on :xcode

  depends_on MaximumMacOSRequirement => :mountain_lion

  # It's actually possible to build with GC disabled, but not advisable.
  # See: https://github.com/tomaz/appledoc/issues/439
  fails_with :clang do
    cause <<-EOS.undent
      clang 5.1 (build 503) removed support for Objective C GC
      which appledoc 2.0 requires to build.
    EOS
  end

  def install
    xcodebuild "-project", "appledoc.xcodeproj",
               "-target", "appledoc",
               "-configuration", "Release",
               "clean", "install",
               "SYMROOT=build",
               "DSTROOT=build",
               "INSTALL_PATH=/bin",
               "OTHER_CFLAGS='-DCOMPILE_TIME_DEFAULT_TEMPLATE_PATH=@\"#{prefix}/Templates\"'"
    bin.install "build/bin/appledoc"
    prefix.install "Templates/"
  end

  test do
    system bin/"appledoc", "--version"
  end
end
