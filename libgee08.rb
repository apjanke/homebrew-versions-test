class Libgee08 < Formula
  homepage "https://wiki.gnome.org/Projects/Libgee"
  url "http://ftp.gnome.org/pub/GNOME/sources/libgee/0.8/libgee-0.8.0.tar.xz"
  sha256 "5e3707cbc1cebea86ab8865682cb28f8f80273869551c3698e396b5dc57831ea"

  bottle do
    cellar :any
    sha256 "71fa029e341ee653ac46ba119cbdc31a61d7477a2b5586dcb2ca1e900941e755" => :yosemite
    sha256 "43d06d6d2d2e6cd6a0c67aa054749df8de92c609fa6fc8cf95e1a049894115ca" => :mavericks
    sha256 "da728c343ef6dd70289da6ebd46207308d2d108e3131920db0383b03a6fbbbfe" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "vala" => :build
  depends_on "gobject-introspection"

  conflicts_with "libgee", :because => "Differing versions of the same formula."

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end
