class LuaRequirement < Requirement
  fatal true
  default_formula "lua"
  satisfy { which "lua" }
end

class Gnuplot4 < Formula
  desc "Command-driven, interactive function plotting"
  homepage "http://www.gnuplot.info"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/4.6.6/gnuplot-4.6.6.tar.gz"
  sha256 "1f19596fd09045f22225afbfec11fa91b9ad1d95b9f48406362f517d4f130274"

  bottle do
    sha256 "231af7bcc0ba62d137d2a191274bbf8030633e8612c773746ae157f0d305a624" => :yosemite
    sha256 "5489c26f250a2d45b7d14c29f047c04a526775edb0d183a580e2d6678a49dec1" => :mavericks
    sha256 "443d876966452eb42a1cf851d3d7cd4ab8c92056383f975a5c533ad4c94c9d27" => :mountain_lion
  end

  option "with-pdf", "Build the PDF terminal using pdflib-lite"
  option "with-wxmac", "Build the wxWidgets terminal using pango"
  option "with-qt", "Build the Qt4 terminal"
  option "with-cairo", "Build the Cairo based terminals"
  option "without-lua", "Build without the lua/TikZ terminal"
  option "with-nogd", "Build without gd support"
  option "with-tests", "Verify the build with make check (1 min)"
  option "without-emacs", "Do not build Emacs lisp files"
  option "with-latex", "Build with LaTeX support"
  option "with-aquaterm", "Build with AquaTerm support"
  option "with-x11", "Build with X11 support"

  depends_on "pkg-config" => :build
  depends_on LuaRequirement if build.with? "lua"
  depends_on "readline"
  depends_on "libpng"
  depends_on "jpeg"
  depends_on "libtiff"
  depends_on "fontconfig"
  depends_on "pango" if (build.with? "cairo") || (build.with? "wxmac")
  depends_on :x11 => :optional
  depends_on "pdflib-lite" => :optional
  depends_on "gd" => :recommended
  depends_on "wxmac" => :optional
  depends_on "qt" => :optional
  depends_on :tex if build.with? "latex"

  def install
    if build.with? "aquaterm"
      # Add "/Library/Frameworks" to the default framework search path, so that an
      # installed AquaTerm framework can be found. Brew does not add this path
      # when building against an SDK (Nov 2013).
      ENV.prepend "CPPFLAGS", "-F/Library/Frameworks"
      ENV.prepend "LDFLAGS", "-F/Library/Frameworks"
    else
      inreplace "configure", "-laquaterm", ""
    end

    # Help configure find libraries
    readline = Formula["readline"].opt_prefix
    pdflib = Formula["pdflib-lite"].opt_prefix
    gd = Formula["gd"].opt_prefix

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-readline=#{readline}
    ]

    args << "--with-pdf=#{pdflib}" if build.with? "pdflib-lite"
    args << ((build.with? "gd") ? "--with-gd=#{gd}" : "--without-gd")

    if build.without? "wxmac"
      args << "--disable-wxwidgets"
      args << "--without-cairo" if build.without? "cairo"
    end

    args << "--enable-qt"             if build.with? "qt"
    args << "--without-lua"           if build.with? "lua"
    args << "--without-lisp-files"    if build.without? "emacs"
    args << ((build.with? "aquaterm") ? "--with-aquaterm" : "--without-aquaterm")
    args << ((build.with? "x11") ? "--with-x" : "--without-x")

    if build.with? "latex"
      args << "--with-latex"
      args << "--with-tutorial"
    else
      args << "--without-latex"
      args << "--without-tutorial"
    end

    system "./configure", *args
    ENV.j1 # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "check" if build.with? "tests"
    system "make", "install"
  end

  test do
    system "#{bin}/gnuplot", "-e", <<-EOS.undent
        set terminal png;
        set output "#{testpath}/image.png";
        plot sin(x);
    EOS
    assert (testpath/"image.png").exist?
  end

  def caveats
    if build.with? "aquaterm"
      <<-EOS.undent
        AquaTerm support will only be built into Gnuplot if the standard AquaTerm
        package from SourceForge has already been installed onto your system.
        If you subsequently remove AquaTerm, you will need to uninstall and then
        reinstall Gnuplot.
      EOS
    end
  end
end
