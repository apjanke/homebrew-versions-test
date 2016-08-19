class Subversion17 < Formula
  desc "Version control system designed to be a better CVS"
  homepage "https://subversion.apache.org/"
  url "https://archive.apache.org/dist/subversion/subversion-1.7.14.tar.bz2"
  sha256 "c4ac8f37eb0ebd38901bfa6f1c7e4d7716d32d7460ee0cee520381ca2f5b120d"
  revision 1

  bottle do
    revision 2
    sha256 "a23dd79e9755459fa60c24a7fa384e9773390aacecbcf37015e65fcb13561877" => :yosemite
    sha256 "0d5c2a17b11d7382f5a3ee85283ebfb1ec181b4005e6e2e27bb920311f22d290" => :mavericks
    sha256 "02a0b33757eb922373afdb7bc0710772b1bd1a13796ef78f805dfd849722b73a" => :mountain_lion
  end

  option :universal
  option "with-java", "Build with Java bindings"
  option "with-perl", "Build with Perl bindings"
  option "with-ruby", "Build with Ruby bindings"
  option "with-unicode-path", "Build with support for OS X UTF-8-MAC filename"

  deprecated_option "java" => "with-java"
  deprecated_option "perl" => "with-perl"
  deprecated_option "ruby" => "with-ruby"
  deprecated_option "unicode-path" => "with-unicode-path"

  resource "serf" do
    url "https://archive.apache.org/dist/serf/serf-1.3.3.tar.bz2"
    sha256 "02eae04176296347be3c32b0da8d8610064f4a9f40065fb1cefbe5b656f8ad2b"
  end

  depends_on "pkg-config" => :build
  depends_on :apr => :build
  depends_on :java

  # Requires system OpenSSL headers to build. >El Capitan no longer ship them.
  # Note this means that this subversion is linked against an outdated OpenSSL
  # and really should not be considered secure.
  depends_on MaximumMacOSRequirement => :yosemite

  # Always build against Homebrew versions instead of system versions for consistency.
  # We don't use our OpenSSL because Neon refuses to support it due to wanting SSLv2
  # and using a more recent Neon via disabling the version check results in segfauls at runtime.
  depends_on :python => :optional
  depends_on "sqlite"

  # Building Ruby bindings requires libtool
  depends_on "libtool" => :build if build.with? "ruby"

  # For Serf
  depends_on "scons" => :build

  # If building bindings, allow non-system interpreters
  if build.with?("perl") || build.with?("ruby")
    env :userpaths

    # When building Perl or Ruby bindings, need to use a compiler that
    # recognizes GCC-style switches, since that's what the system languages
    # were compiled against.
    fails_with :clang do
      build 318
      cause "core.c:1: error: bad value (native) for -march= switch"
    end
  end

  # Patch for Subversion handling of OS X UTF-8-MAC filename.
  if build.with? "unicode-path"
    patch :p0 do
      url "https://gist.githubusercontent.com/jeffstyr/3044094/raw/1648c28f6133bcbb68b76b42669b0dc237c02dba/patch-path.c.diff"
      sha256 "c48bab1fbdc5d8e509a03a3413338d42e49d9be3acefdebb7a956cefa63ea310"
    end
  end

  # Patch to prevent "-arch ppc" from being pulled in from Perl's $Config{ccflags}
  patch :p0, :DATA if build.with? "perl"

  resource "neon" do
    url "http://webdav.org/neon/neon-0.29.6.tar.gz"
    sha256 "9c640b728d6dc80ef1e48f83181166ab6bc95309cece5537e01ffdd01b96eb43"
  end

  def install
    # OS X's Python is built universally and can't link with Homebrew's deps
    # unless Homebrew's deps are universal as well.
    # https://github.com/Homebrew/homebrew-versions/issues/777
    if build.with?("python") && (which "python").universal?
      unless build.universal?
        raise <<-EOS.undent
          You must build subversion --universal unless Homebrew's
          Python is installed, otherwise the build will fail.
        EOS
      end
    end

    # Homebrew's Neon is too new and causes problems.
    resource("neon").stage do
      system "./configure", "--prefix=#{libexec}/neon", "--enable-shared",
                            "--disable-static", "--disable-nls", "--with-ssl=openssl",
                            "--with-libs=/usr/lib"
      system "make", "install"
    end

    ENV.prepend_path "PATH", libexec/"neon/bin"
    ENV.prepend "CFLAGS", "-I#{libexec}/neon/include"
    ENV.prepend "LDFLAGS", "-L#{libexec}/neon/lib"
    ENV.prepend_path "PKG_CONFIG_PATH", libexec/"neon/lib/pkgconfig"

    serf_prefix = libexec+"serf"

    resource("serf").stage do
      # SConstruct merges in gssapi linkflags using scons's MergeFlags,
      # but that discards duplicate values - including the duplicate
      # values we want, like multiple -arch values for a universal build.
      # Passing 0 as the `unique` kwarg turns this behaviour off.
      inreplace "SConstruct", "unique=1", "unique=0"

      ENV.universal_binary if build.universal?
      # scons ignores our compiler and flags unless explicitly passed
      args = %W[PREFIX=#{serf_prefix} GSSAPI=/usr CC=#{ENV.cc}
                CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}]

      unless MacOS::CLT.installed?
        args << "APR=#{Formula["apr"].opt_prefix}"
        args << "APU=#{Formula["apr-util"].opt_prefix}"
      end

      scons(*args)
      scons "install"
    end

    # Java support doesn't build correctly in parallel:
    # https://github.com/mxcl/homebrew/issues/20415
    ENV.deparallelize

    if build.with? "java"
      unless build.universal?
        opoo "A non-Universal Java build was requested."
        puts "To use Java bindings with various Java IDEs, you might need a universal build:"
        puts "  brew install subversion --universal --java"
      end
    end

    ENV.universal_binary if build.universal?

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-zlib=/usr",
            "--with-sqlite=#{Formula["sqlite"].opt_prefix}",
            "--with-serf=#{serf_prefix}",
            "--enable-neon-version-check",
            "--disable-mod-activation",
            "--disable-nls",
            "--without-apache-libexecdir",
            "--without-berkeley-db"]

    args << "--enable-javahl" << "--without-jikes" if build.with? "java"

    if MacOS::CLT.installed?
      args << "--with-apr=/usr"
      args << "--with-apr-util=/usr"
    else
      args << "--with-apr=#{Formula["apr"].opt_prefix}"
      args << "--with-apr-util=#{Formula["apr-util"].opt_prefix}"
      args << "--with-apxs=no"
    end

    if build.with? "ruby"
      args << "--with-ruby-sitedir=#{lib}/ruby"
      # Peg to system Ruby
      args << "RUBY=/usr/bin/ruby"
    end

    # The system Python is built with llvm-gcc, so we override this
    # variable to prevent failures due to incompatible CFLAGS
    ENV["ac_cv_python_compile"] = ENV.cc

    inreplace "Makefile.in",
              "toolsdir = @bindir@/svn-tools",
              "toolsdir = @libexecdir@/svn-tools"

    system "./configure", *args
    system "make"
    system "make", "install"
    bash_completion.install "tools/client-side/bash_completion" => "subversion"

    system "make", "tools"
    system "make", "install-tools"

    if build.with? "python"
      system "make", "swig-py"
      system "make", "install-swig-py"
    end

    if build.with? "perl"
      # Remove hard-coded ppc target, add appropriate ones
      if build.universal?
        arches = Hardware::CPU.universal_archs.as_arch_flags
      elsif MacOS.version <= :leopard
        arches = "-arch #{Hardware::CPU.arch_32_bit}"
      else
        arches = "-arch #{Hardware::CPU.arch_64_bit}"
      end

      perl_core = Pathname.new(`perl -MConfig -e 'print $Config{archlib}'`)+"CORE"
      unless perl_core.exist?
        onoe "perl CORE directory does not exist in '#{perl_core}'"
      end

      inreplace "Makefile" do |s|
        s.change_make_var! "SWIG_PL_INCLUDES",
          "$(SWIG_INCLUDES) #{arches} -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -I/usr/local/include -I#{perl_core}"
      end
      system "make", "swig-pl"
      system "make", "install-swig-pl", "DESTDIR=#{prefix}"
      lib.install_symlink Dir["#{prefix}/#{lib}/*"]
      man3.install_symlink Dir["#{prefix}/#{HOMEBREW_PREFIX}/share/man/man3/*"]
    end

    if build.with? "java"
      system "make", "javahl"
      system "make", "install-javahl"
    end

    if build.with? "ruby"
      # Peg to system Ruby
      system "make", "swig-rb", "EXTRA_SWIG_LDFLAGS=-L/usr/lib"
      system "make", "install-swig-rb"
    end
  end

  def caveats
    s = <<-EOS.undent
      svntools have been installed to:
        #{opt_libexec}
    EOS

    if build.with? "perl"
      s += <<-EOS.undent
        The perl bindings are located in various subdirectories of:
          #{prefix}/Library/Perl

      EOS
    end

    if build.with? "ruby"
      s += <<-EOS.undent
        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby

      EOS
    end

    if build.with? "java"
      s += <<-EOS.undent
        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{HOMEBREW_PREFIX}/lib/libsvnjavahl-1.dylib /Library/Java/Extensions/libsvnjavahl-1.dylib

      EOS
    end

    if build.with? "unicode-path"
      s += <<-EOS.undent
        This unicode-path version implements a hack to deal with composed/decomposed
        unicode handling on Mac OS X which is different from linux and windows.
        It is an implementation of solution 1 from
        http://svn.collab.net/repos/svn/trunk/notes/unicode-composition-for-filenames
        which _WILL_ break some setups. Please be sure you understand what you
        are asking for when you install this version.

      EOS
    end

    s
  end

  test do
    system "#{bin}/svnadmin", "create", "test"
    system "#{bin}/svnadmin", "verify", "test"
  end
end

__END__
--- subversion/bindings/swig/perl/native/Makefile.PL.in~	2011-07-16 04:47:59.000000000 -0700
+++ subversion/bindings/swig/perl/native/Makefile.PL.in	2012-06-27 17:45:57.000000000 -0700
@@ -57,10 +57,13 @@
 
 chomp $apr_shlib_path_var;
 
+my $config_ccflags = $Config{ccflags};
+$config_ccflags =~ s/-arch\s+\S+//g; # remove any -arch arguments, since the ones we want will already be in $cflags
+
 my %config = (
     ABSTRACT => 'Perl bindings for Subversion',
     DEFINE => $cppflags,
-    CCFLAGS => join(' ', $cflags, $Config{ccflags}),
+    CCFLAGS => join(' ', $cflags, $config_ccflags),
     INC  => join(' ',$apr_cflags, $apu_cflags,
                  " -I$swig_srcdir/perl/libsvn_swig_perl",
                  " -I$svnlib_srcdir/include",
