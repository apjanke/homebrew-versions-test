class Gegl02 < Formula
  desc "Graph based image processing framework"
  homepage "http://www.gegl.org/"
  url "http://download.gimp.org/pub/gegl/0.2/gegl-0.2.0.tar.bz2"
  mirror "https://mirrors.kernel.org/debian/pool/main/g/gegl/gegl_0.2.0.orig.tar.bz2"
  sha256 "df2e6a0d9499afcbc4f9029c18d9d1e0dd5e8710a75e17c9b1d9a6480dd8d426"

  bottle do
    sha256 "14115d50a45db389363bff603b9c2d9d74ecd01caad2e6758bae664168ff6a0f" => :yosemite
    sha256 "5ce386ef6e4245047afac0ee6c069b737c494a1adb8bf8250997d6545785a701" => :mavericks
    sha256 "58a60436bd7aa4d5eb0724ea856a5013a9cbc38f269564a8a52724e34d96005d" => :mountain_lion
  end

  option :universal

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "babl"
  depends_on "glib"
  depends_on "gettext"
  depends_on "libpng"
  depends_on "jpeg" => :optional
  depends_on "lua" => :optional
  depends_on "cairo" => :optional
  depends_on "pango" => :optional
  depends_on "librsvg" => :optional
  depends_on "sdl" => :optional

  keg_only "Older version of core gegl"

  def install
    # ./configure breaks when optimization is enabled with llvm
    ENV.no_optimization if ENV.compiler == :llvm

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --disable-docs
    ]

    if build.universal?
      ENV.universal_binary
      # ffmpeg's formula is currently not universal-enabled
      args << "--without-libavformat"

      opoo "Compilation may fail at gegl-cpuaccel.c using gcc for a universal build" if ENV.compiler == :gcc
    end

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <gegl.h>
      gint main(gint argc, gchar **argv) {
        gegl_init(&argc, &argv);
        GeglNode *gegl = gegl_node_new ();
        gegl_exit();
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}/gegl-0.2", "-L#{lib}", "-lgegl-0.2",
           "-I#{Formula["babl"].opt_include}/babl-0.1",
           "-I#{Formula["glib"].opt_include}/glib-2.0",
           "-I#{Formula["glib"].opt_lib}/glib-2.0/include",
           "-L#{Formula["glib"].opt_lib}", "-lgobject-2.0", "-lglib-2.0",
           testpath/"test.c", "-o", testpath/"test"
    system "./test"
  end
end
