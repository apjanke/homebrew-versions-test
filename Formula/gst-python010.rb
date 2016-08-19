class GstPython010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "http://gstreamer.freedesktop.org/src/gst-python/gst-python-0.10.22.tar.bz2"
  sha256 "8f26f519a5bccd770864317e098e5e307fc5ad1201eb96329634b6508b253178"

  bottle do
    sha256 "8733d920b1b69bb171774c6e399071ed58c1a2e687c612f380947d5e1fea1e83" => :yosemite
    sha256 "d526f793ea62bd1a298aecfb6a635105303a8230cd43338fde43e3b12161cebd" => :mavericks
    sha256 "13be6f9f7c40553c881363bf6a494e823bf1628b0996e4183b26e03eae652b8a" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gst-plugins-base010"
  depends_on "pygtk"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    For non-Homebrew Python, you need to amend your PYTHONPATH like so:
      export PYTHONPATH=#{HOMEBREW_PREFIX}/lib/#{which_python}/site-packages:$PYTHONPATH
    EOS
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  test do
    (testpath/"test.py").write <<-EOS.undent
      #!/usr/bin/env python

      import time

      import pygst
      pygst.require('0.10')
      import gst

      import gobject
      gobject.threads_init()

      def main():
          pipeline = gst.parse_launch(
              'audiotestsrc ! audioresample ! fakesink')
          pipeline.set_state(gst.STATE_PLAYING)
          time.sleep(3)

      if __name__ == "__main__":
          main()
    EOS
    chmod 0755, "test.py"
    system "./test.py"
  end
end
