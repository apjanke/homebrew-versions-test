# The 2.2 series introduces support for documenting enumerated and
# bitmask types, but will emit warnings on encountering undocumented
# instances of those types.  2.1 (build 840) is provided to allow
# projects to successfully build with undocumented enumerated and
# bitmask types.
class Appledoc21 < Formula
  desc "Objective-C API documentation generator"
  homepage "http://appledoc.gentlebytes.com/"
  url "https://github.com/tomaz/appledoc/archive/v2.1.tar.gz"
  sha256 "cfb014202bba878a72babf8bfce2d9ddb34b6226b09fa1c9742243af0118797a"

  keg_only :provided_by_osx, <<-EOS.undent
   The executable installed by this formula may be invoked explicitly,
   or (if it is the only version installed) linked after it is installed.
  EOS

  depends_on :xcode
  depends_on :macos => :lion

  depends_on MaximumMacOSRequirement => :mountain_lion

  # It's actually possible to build with GC disabled, but not advisable.
  # See: https://github.com/tomaz/appledoc/issues/439
  fails_with :clang do
    cause <<-EOS.undent
      clang 5.1 (build 503) removed support for Objective C GC
      which appledoc 2.1 requires to build.
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
