class Cvsps2 < Formula
  desc "Create patchset information from CVS"
  homepage "http://www.catb.org/~esr/cvsps/"
  url "https://mirrors.ocf.berkeley.edu/debian/pool/main/c/cvsps/cvsps_2.1.orig.tar.gz"
  mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/c/cvsps/cvsps_2.1.orig.tar.gz"
  sha256 "91d3198b33463861a581686d5fcf99a5c484e7c4d819384c04fda9cafec1075a"

  bottle do
    cellar :any
    sha256 "b8c56242eeab6032ea45267eda778852ed8101a6403ffbe570a39040849a7292" => :yosemite
    sha256 "c28f907d790d36bdb5afdb3acccf604b8dbf10c3208ffd545e6040374fcb4988" => :mavericks
    sha256 "37eed6e3d42ae1163b1ea40c246c9877e8f1737588b8654d4d6b28620f9b8c0c" => :mountain_lion
  end

  def install
    system "make", "all"
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    # an assert_match on shell_output hangs indefinitely, as does normal syntax usage.
    assert_match "special hack for parsing the", pipe_output("#{bin}/cvsps -h 2>&1")
  end
end
