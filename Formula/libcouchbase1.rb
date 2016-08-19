class Libcouchbase1 < Formula
  desc "C library for Couchbase"
  homepage "http://couchbase.com/develop/c/current"
  url "http://packages.couchbase.com/clients/c/libcouchbase-1.0.6.tar.gz"
  sha256 "ff86530a0fc21a2a6b719b389163a1f5172e379630b7dc91cbd2d16b5d586dc7"

  bottle do
    cellar :any
    sha256 "52edba8b85ce6eeeab3f78dd37c72568ad868e47b8609398686eeb48c3fa5017" => :yosemite
    sha256 "e21141ffd802673540b89ff710526803fb24f8d82e962d4b095b315ee691836d" => :mavericks
    sha256 "97c87c221ffdf93a07f03bf7b5ea5007ef17803a27f24d63a78151a27169272f" => :mountain_lion
  end

  conflicts_with "libcouchbase", :because => "Differing versions of the same formula."

  depends_on "libevent"
  depends_on "libvbucket"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-couchbasemock"
    system "make", "install"
  end

  test do
    system "#{bin}/cbc-version"
  end
end
