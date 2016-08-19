# Most recent ocaml supported by camlp5-606 & consequently coq83.
class ObjectiveCaml312 < Formula
  homepage "http://ocaml.org"
  url "http://caml.inria.fr/pub/distrib/ocaml-3.12/ocaml-3.12.1.tar.bz2"
  sha256 "edcf563da75e0b91f09765649caa98ab1535e0c7498f0737b5591b7de084958d"

  bottle do
    sha256 "c6f0d0c36a7e45097b1c5b96ff159d6049d691828369bcef6a481bad071413eb" => :yosemite
    sha256 "2bd5864b49e5db08188649c02eea5de34799a17bc95b942d1ce5a70464d09273" => :mavericks
    sha256 "f529118355c17b749545898977a4e8e8f8ed5e72cb561e522fdf7516c0348d8a" => :mountain_lion
  end

  depends_on :x11 # Mandatory or compile = nope.

  conflicts_with "objective-caml", :because => "both install an ocaml binary"

  patch do
    url "http://caml.inria.fr/mantis/file_download.php?file_id=723&type=bug"
    sha256 "fd12a787c4b0604f78781b35c0f531cacb3d9e62831c91ae7d28848c8945fba7"
  end

  def install
    args = %W[
      --prefix #{HOMEBREW_PREFIX}
      --mandir #{man}
      -x11include #{MacOS::X11.include}
      -x11lib #{MacOS::X11.lib}
      -cc #{ENV.cc} #{ENV.cflags}
      -aspp #{ENV.cc} #{ENV.cflags} -c
    ]

    system "./configure", *args

    ENV.deparallelize # Builds are not parallel-safe, esp. with many cores
    system "make", "world"
    system "make", "opt"
    system "make", "opt.opt"
    system "make", "PREFIX=#{prefix}", "install"
    (lib+"ocaml/compiler-libs").install "typing", "parsing", "utils"
  end

  test do
    system bin/"ocaml", "-version"
  end
end
