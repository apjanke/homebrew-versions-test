class Povray36 < Formula
  desc "Persistence Of Vision RAYtracer (POVRAY)"
  homepage "http://www.povray.org/"
  url "http://www.povray.org/ftp/pub/povray/Old-Versions/Official-3.62/Unix/povray-3.6.1.tar.bz2"
  sha256 "4e8a7fecd44807343b6867e1f2440aa0e09613d6d69a7385ac48f4e5e7737a73"

  bottle do
    sha256 "b4c715205c566890afc176085d22dc5de47aa1db8b644edfb5223ac18f4b20e9" => :yosemite
    sha256 "d2ca035fdb3a98363c038f93edc825309261019d2b329a2d13bd153f573f7a94" => :mavericks
    sha256 "0ebfed92b039a7b61606dd0639de9fadcf0eeed9ba750dd24e5e5c168492b7a4" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "jpeg"
  depends_on "libtiff"

  conflicts_with "libpng",
    :because => "causes fatal build error. You can and should `brew link libpng` again after installation"

  if MacOS.version == :leopard
    fails_with :llvm do
      build 2326
      cause "povray fails with 'terminate called after throwing an instance of int'"
    end
  end

  # povray has issues determining libpng version; can't get it to compile
  # against system libpng, but it works with its internal libpng.
  patch :p0 do
    url "https://trac.macports.org/export/97719/trunk/dports/graphics/povray/files/patch-configure"
    sha256 "b98062784156ffe5fbc6b38a33d3819f45c759d2890e3ee18efbb3e505fe1e69"
  end

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "COMPILED_BY=Homebrew", "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end

  test do
    system bin/"povray", "-h"
  end
end
