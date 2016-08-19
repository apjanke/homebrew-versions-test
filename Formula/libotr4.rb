class Libotr4 < Formula
  desc "Off-The-Record (OTR) messaging library"
  homepage "https://otr.cypherpunks.ca/"
  url "https://otr.cypherpunks.ca/libotr-4.0.0.tar.gz"
  sha256 "3f911994409898e74527730745ef35ed75c352c695a1822a677a34b2cf0293b4"

  bottle do
    cellar :any
    sha256 "5e123d6699df1de4ba60a54a298969abed51582f26a9dea376f2edb3f64c8f89" => :yosemite
    sha256 "4d49d2e193e6dcf5eeb60d096ffe8650dec6bd90145cfe120d6de38f37bca0bc" => :mavericks
    sha256 "5ddaa483401d5d6c84a58f088f713f326869031eeefe3360c0d3a0e1112d4661" => :mountain_lion
  end

  depends_on "libgcrypt"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--mandir=#{man}"
    system "make", "install"
  end
end
