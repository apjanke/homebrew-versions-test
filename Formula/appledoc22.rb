# 2.2 (build 961) introduces support for documenting enumerated and
# bitmask types, and will emit warnings on encountering undocumented
# instances of those types.  An archived release is provided as a stable
# dependency for e.g. continuous integration environments.
class Appledoc22 < Formula
  desc "Objective-C API documentation generator"
  homepage "http://appledoc.gentlebytes.com/"
  url "https://github.com/tomaz/appledoc/archive/2.2.1.tar.gz"
  sha256 "0ec881f667dfe70d565b7f1328e9ad4eebc8699ee6dcd381f3bd0ccbf35c0337"

  bottle do
    revision 1
    sha256 "8ce8785d092cd3cf22ad0266ba51c7cb514e381a6481305572db170a2a5b5f8e" => :yosemite
    sha256 "3ff1135e32ec900932270ce5353baf906a85c86a20c1bc6ef3b93c4d50439d89" => :mavericks
    sha256 "a1b3d3a41cc2080dc2bf9e4d3907166e994d0c22dcf0ad323e243184f54fce09" => :mountain_lion
  end

  keg_only :provided_by_osx, <<-EOS.undent
   The executable installed by this formula may be invoked explicitly,
   or (if it is the only version installed) linked after it is installed.
  EOS

  depends_on :xcode
  depends_on :macos => :lion

  # Actually works with pre-503 clang, but we don't have a way to
  # express this yet.
  # It's actually possible to build with GC disabled, but not advisable.
  # See: https://github.com/tomaz/appledoc/issues/439
  fails_with :clang do
    cause <<-EOS.undent
      clang 5.1 (build 503) removed support for Objective C GC
      which appledoc 2.2 requires to build.
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
    system "#{bin}/appledoc", "--version"
  end
end
