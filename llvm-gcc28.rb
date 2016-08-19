class LlvmGcc28 < Formula
  desc "LLVM C front-end"
  homepage "http://llvm.org/releases/2.8/docs/CommandGuide/html/llvmgcc.html"
  url "http://llvm.org/releases/2.8/llvm-gcc-4.2-2.8-x86_64-apple-darwin10.tar.gz"
  version "2.8"
  sha256 "c359d13f658a6de028615554f350053e6dd8c1cb82fe3716cffbd4c27e703bdf"

  bottle :unneeded

  keg_only :provided_by_osx

  def install
    prefix.install Dir["*"]
  end
end
