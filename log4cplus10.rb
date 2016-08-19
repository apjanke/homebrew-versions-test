class Log4cplus10 < Formula
  desc "Logging Framework for C++"
  homepage "http://log4cplus.sourceforge.net/"
  url "https://downloads.sourceforge.net/project/log4cplus/log4cplus-stable/1.0.4/log4cplus-1.0.4.3.tar.bz2"
  sha256 "9af936fc4a25c3a59b7ae2c34ce95e08e8a705797ffe27e13272c01732649491"

  bottle do
    cellar :any
    sha256 "f005657c98f3eb20b038124a4ee15898de2fc5de45b0ce9d7cc23a2d58b62a64" => :yosemite
    sha256 "c1fb62f4325ca3d7c7f6aa7167bf7b821214347a5565fe4279f61f2d523254a9" => :mavericks
    sha256 "22b20f59258f8c950876c85f5eff6a3a9d7339b8e2d3374e7fdc9c21f83b4ccc" => :mountain_lion
  end

  keg_only "Differing version of the same formula shipped in Homebrew/homebrew"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end
end
