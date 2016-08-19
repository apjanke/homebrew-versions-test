class Doxygen1831 < Formula
  homepage "http://www.stack.nl/~dimitri/doxygen/"
  url "http://ftp.stack.nl/pub/users/dimitri/doxygen-1.8.3.1.src.tar.gz"
  mirror "https://downloads.sourceforge.net/project/doxygen/rel-1.8.3.1/doxygen-1.8.3.1.src.tar.gz"
  sha256 "0c749f68101b6c04ccb0d9696dd37836a6ba62cd8002add275058a975ee72b55"

  bottle do
    cellar :any
    sha256 "64977dcd670dad96123eb960e0d3c10aabc77a54581fcd80b1d739e2944bfa66" => :yosemite
    sha256 "75ea3c6a589dee81e8ca790a9c9a17aa008be2dd8c392add690a01cf37e91a63" => :mavericks
    sha256 "e9ca771c72c9ca33d4a3cd5b0def2059c061b156e348e651c2b4d023f1106688" => :mountain_lion
  end

  option "with-graphviz", "Build with dot command support from Graphviz."
  option "with-doxywizard", "Build GUI frontend with qt support."
  option "with-libclang", "Build with libclang support."

  deprecated_option "with-dot" => "with-graphviz"

  depends_on "graphviz" => :optional
  depends_on "qt" if build.with? "doxywizard"
  depends_on "llvm" => "with-clang" if build.with? "libclang"

  # Fixes for --with-doxywizard
  patch :DATA

  def install
    # libclang is installed under #{HOMEBREW_PREFIX}/opt/llvm/
    if build.with? "libclang"
      args << "--with-libclang-static"

      llvm = Formula["llvm"]
      inreplace "configure" do |s|
        s.gsub! /libclang_hdr_dir=\".*$/, "libclang_hdr_dir=\"#{llvm.opt_include}\""
        s.gsub! /libclang_lib_dir=\".*$/, "libclang_lib_dir=\"#{llvm.opt_lib}\""
      end
    end

    args = ["--prefix", prefix]
    args << "--with-doxywizard" if build.with? "doxywizard"
    system "./configure", *args

    # Per Macports:
    # https://trac.macports.org/browser/trunk/dports/textproc/doxygen/Portfile#L92
    inreplace %w[ libmd5/Makefile.libmd5
                  src/Makefile.libdoxycfg
                  tmake/lib/macosx-c++/tmake.conf
                  tmake/lib/macosx-intel-c++/tmake.conf
                  tmake/lib/macosx-uni-c++/tmake.conf ] do |s|
      # makefiles hardcode both cc and c++
      s.gsub! /cc$/, ENV.cc
      s.gsub! /c\+\+$/, ENV.cxx
    end

    # This is a terrible hack; configure finds lex/yacc OK but
    # one Makefile doesn't get generated with these, so pull
    # them out of a known good file and cram them into the other.
    lex = ""
    yacc = ""

    inreplace "src/libdoxycfg.t" do |s|
      lex = s.get_make_var "LEX"
      yacc = s.get_make_var "YACC"
    end

    inreplace "src/Makefile.libdoxycfg" do |s|
      s.change_make_var! "LEX", lex
      s.change_make_var! "YACC", yacc
    end

    system "make"
    # MAN1DIR, relative to the given prefix
    system "make", "MAN1DIR=share/man/man1", "install"
  end

  test do
    system "#{bin}/doxygen", "-g"
    system "#{bin}/doxygen", "Doxyfile"
  end
end

__END__
# On Mac OS Qt builds an application bundle rather than a binary.  We need to
# give install the correct path to the doxywizard binary.  This is similar to
# what macports does:
diff --git a/addon/doxywizard/Makefile.in b/addon/doxywizard/Makefile.in
index 727409a..8b0d00f 100644
--- a/addon/doxywizard/Makefile.in
+++ b/addon/doxywizard/Makefile.in
@@ -30,7 +30,7 @@ distclean: Makefile.doxywizard
 
 install:
 	$(INSTTOOL) -d $(INSTALL)/bin	
-	$(INSTTOOL) -m 755 ../../bin/doxywizard $(INSTALL)/bin	
+	$(INSTTOOL) -m 755 ../../bin/doxywizard.app/Contents/MacOS/doxywizard $(INSTALL)/bin
 	$(INSTTOOL) -d $(INSTALL)/$(MAN1DIR)
 	cat ../../doc/doxywizard.1 | sed -e "s/DATE/$(DATE)/g" -e "s/VERSION/$(VERSION)/g" > doxywizard.1
 	$(INSTTOOL) -m 644 doxywizard.1 $(INSTALL)/$(MAN1DIR)/doxywizard.1
