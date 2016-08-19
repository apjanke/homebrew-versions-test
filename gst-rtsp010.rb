class GstRtsp010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "http://gstreamer.freedesktop.org/src/gst-rtsp/gst-rtsp-0.10.8.tar.bz2"
  sha256 "9915887cf8515bda87462c69738646afb715b597613edc7340477ccab63a6617"

  bottle do
    cellar :any
    sha256 "7ed3612a628ad6a01f44c6004ecc315125b5316ec04101a264548d10212d5b6a" => :yosemite
    sha256 "159f46f882b63c1ea06fe3d30b4a0b41a44badd233af8f911f2da51778cd16d6" => :mavericks
    sha256 "a83e1ddb511a1d42fd3157f87e7cf71131cecf0cedd34ebf7523a11bdc7ff752" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base010"

  def install
    system "./configure",  "--disable-debug", "--disable-dependency-tracking",
                           "--prefix=#{prefix}", "--disable-gtk-doc"
    system "make"
    system "make", "install"
  end
end
