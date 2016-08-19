class Camlp5606 < Formula
  homepage "http://pauillac.inria.fr/~ddr/camlp5/"
  url "http://pauillac.inria.fr/~ddr/camlp5/distrib/src/camlp5-6.06.tgz"
  sha256 "763f89ee6cde4ca063a50708c3fe252d55ea9f8037e3ae9801690411ea6180c5"

  bottle do
    sha256 "f8bf23c6b7c2be15b75b9473dd4c877c1f507e41ee569496365a7d230a2563af" => :yosemite
    sha256 "454762aac44d7c87694b767a9d2b487385b0e1d33767060144e8b1c5ac467765" => :mavericks
    sha256 "eb0015f2273826e0907229d5d7166b1f5497795c878c701462c8b9041ab6b57e" => :mountain_lion
  end

  option "with-strict", "Compile in strict mode"

  depends_on "objective-caml312"

  conflicts_with "camlp5", :because => "both install an camlp5 binary"

  def install
    if build.with? "strict"
      strictness = "-strict"
    else
      strictness = "-transitional"
    end

    system "./configure", "-prefix", prefix, "-mandir", man, strictness
    # this build fails if jobs are parallelized
    ENV.deparallelize
    system "make", "world.opt"
    system "make", "install"
  end

  test do
    system bin/"camlp5", "-v"
  end
end
