class Llvm35 < Formula
  desc "Next-gen compiler infrastructure"
  homepage "http://llvm.org/"

  stable do
    url "http://llvm.org/releases/3.5.1/llvm-3.5.1.src.tar.xz"
    sha256 "bf3275d2d7890015c8d8f5e6f4f882f8cf3bf51967297ebe74111d6d8b53be15"

    resource "clang" do
      url "http://llvm.org/releases/3.5.1/cfe-3.5.1.src.tar.xz"
      sha256 "6773f3f9cf815631cc7e779ec134ddd228dc8e9a250e1ea3a910610c59eb8f5c"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/releases/3.5.1/clang-tools-extra-3.5.1.src.tar.xz"
      sha256 "e8d011250389cfc36eb51557ca25ae66ab08173e8d53536a0747356105d72906"
    end

    resource "compiler-rt" do
      url "http://llvm.org/releases/3.5.1/compiler-rt-3.5.1.src.tar.xz"
      sha256 "adf4b526f33e681aff5961f0821f5b514d3fc375410008842640b56a2e6a837a"
    end

    resource "polly" do
      url "http://llvm.org/releases/3.5.1/polly-3.5.1.src.tar.xz"
      sha256 "ac12ec5ff2119ac1d2916c105920e1880321a7d97b6f5ec5957a588450704f04"
    end

    resource "lld" do
      url "http://llvm.org/releases/3.5.1/lld-3.5.1.src.tar.xz"
      sha256 "f29f684723effd204b6fe96edb1bf2f66f0f81297230bc92b8cc514f7a24236f"
    end

    resource "lldb" do
      url "http://llvm.org/releases/3.5.1/lldb-3.5.1.src.tar.xz"
      sha256 "e8b948c6c85cd61bd9a48361959401b9c631fa257c0118db26697c5d57460e13"
    end

    resource "libcxx" do
      url "http://llvm.org/releases/3.5.1/libcxx-3.5.1.src.tar.xz"
      sha256 "a16d0ae0c0cf2c8cebb94fafcb907022cd4f8579ebac99a4c9919990a37ad475"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/releases/3.5.1/libcxxabi-3.5.1.src.tar.xz"
        sha256 "7ff14fdce0ed7bfcc532c627c7a2dc7876dd8a3d788b2aa201d3bbdc443d06a3"
      end
    end
  end

  bottle do
    revision 4
    sha256 "0049fccd96ac0047c3619e9262945cb8d87512a75791c9dcb7ddc16a8cc81062" => :el_capitan
    sha256 "f85175cebf2e08b80383dceb057fbd5c986c2c0803b98211c49974a67dabfbba" => :yosemite
    sha256 "ad1df4e607f8766d2d594cdc7edfe9f225de00e0ed8080f76e9e9fe3f542a90b" => :mavericks
  end

  head do
    url "http://llvm.org/git/llvm.git", :branch => "release_35"

    resource "clang" do
      url "http://llvm.org/git/clang.git", :branch => "release_35"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/git/clang-tools-extra.git", :branch => "release_35"
    end

    resource "compiler-rt" do
      url "http://llvm.org/git/compiler-rt.git", :branch => "release_35"
    end

    resource "polly" do
      url "http://llvm.org/git/polly.git", :branch => "release_35"
    end

    resource "lld" do
      url "http://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "http://llvm.org/git/lldb.git"
    end

    resource "libcxx" do
      url "http://llvm.org/git/libcxx.git", :branch => "release_35"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/git/libcxxabi.git"
      end
    end
  end

  resource "isl" do
    url "http://isl.gforge.inria.fr/isl-0.13.tar.bz2"
    sha256 "7265fd897b7f9147fde76560f28ed18f2c20e5f5da7f4bd9d0e01f8a713401f1"
  end

  resource "cloog" do
    url "http://repo.or.cz/cloog.git",
    :revision => "22643c94eba7b010ae4401c347289f4f52b"
  end

  patch :DATA

  option :universal
  option "with-lld", "Build LLD linker"
  option "with-lldb", "Build LLDB debugger"
  option "with-asan", "Include support for -faddress-sanitizer (from compiler-rt)"
  option "with-all-targets", "Build all target backends"
  option "with-python", "Build lldb bindings against the python in PATH instead of system Python"
  option "without-shared", "Don't build LLVM as a shared library"
  option "without-assertions", "Speeds up LLVM, but provides less debug information"

  deprecated_option "all-targets" => "with-all-targets"
  deprecated_option "disable-shared" => "without-shared"
  deprecated_option "disable-assertions" => "without-assertions"

  # required to build cloog
  depends_on "automake" => :build
  depends_on "autoconf" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "gmp"
  depends_on "libffi" => :recommended

  depends_on "swig" if build.with? "lldb"
  depends_on :python => :optional

  # version suffix
  def ver
    "3.5"
  end

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc
  fails_with :llvm

  def install
    # Apple's libstdc++ is too old to build LLVM
    ENV.libcxx if ENV.compiler == :clang

    clang_buildpath = buildpath/"tools/clang"
    libcxx_buildpath = buildpath/"projects/libcxx"
    libcxxabi_buildpath = buildpath/"libcxxabi" # build failure if put in projects due to no Makefile

    clang_buildpath.install resource("clang")
    libcxx_buildpath.install resource("libcxx")
    (buildpath/"tools/polly").install resource("polly")
    (buildpath/"tools/clang/tools/extra").install resource("clang-tools-extra")
    (buildpath/"tools/lld").install resource("lld") if build.with? "lld"
    (buildpath/"tools/lldb").install resource("lldb") if build.with? "lldb"
    (buildpath/"projects/compiler-rt").install resource("compiler-rt") if build.with? "asan"

    if build.universal?
      ENV.permit_arch_flags
      ENV["UNIVERSAL"] = "1"
      ENV["UNIVERSAL_ARCH"] = Hardware::CPU.universal_archs.join(" ")
    end

    ENV["REQUIRES_RTTI"] = "1"

    install_prefix = lib/"llvm-#{ver}"

    gmp_prefix = Formula["gmp"].opt_prefix
    isl_prefix = install_prefix/"libexec/isl"
    cloog_prefix = install_prefix/"libexec/cloog"

    resource("isl").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{isl_prefix}",
                            "--with-gmp=system",
                            "--with-gmp-prefix=#{gmp_prefix}"
      system "make"
      system "make", "install"
    end

    resource("cloog").stage do
      system "./autogen.sh"
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{cloog_prefix}",
                            "--with-gmp-prefix=#{gmp_prefix}",
                            "--with-isl-prefix=#{isl_prefix}"
      system "make"
      system "make", "install"
    end

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      "--disable-bindings",
      "--with-gmp=#{gmp_prefix}",
      "--with-isl=#{isl_prefix}",
      "--with-cloog=#{cloog_prefix}",
    ]

    if build.with? "all-targets"
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end

    args << "--enable-shared" if build.with? "shared"

    args << "--disable-assertions" if build.without? "assertions"

    args << "--enable-libffi" if build.with? "libffi"

    system "./configure", *args
    system "make", "VERBOSE=1"
    system "make", "VERBOSE=1", "install"

    if MacOS.version <= :snow_leopard
      libcxxabi_buildpath.install resource("libcxxabi")

      cd libcxxabi_buildpath/"lib" do
        # Set rpath to save user from setting DYLD_LIBRARY_PATH
        inreplace "buildit", "-install_name /usr/lib/libc++abi.dylib", "-install_name #{install_prefix}/usr/lib/libc++abi.dylib"

        ENV["CC"] = "#{install_prefix}/bin/clang"
        ENV["CXX"] = "#{install_prefix}/bin/clang++"
        ENV["TRIPLE"] = "*-apple-*"
        system "./buildit"
        (install_prefix/"usr/lib").install "libc++abi.dylib"
        cp libcxxabi_buildpath/"include/cxxabi.h", install_prefix/"lib/c++/v1"
      end

      # Snow Leopard make rules hardcode libc++ and libc++abi path.
      # Change to Cellar path here.
      inreplace "#{libcxx_buildpath}/lib/buildit" do |s|
        s.gsub! "-install_name /usr/lib/libc++.1.dylib", "-install_name #{install_prefix}/usr/lib/libc++.1.dylib"
        s.gsub! "-Wl,-reexport_library,/usr/lib/libc++abi.dylib", "-Wl,-reexport_library,#{install_prefix}/usr/lib/libc++abi.dylib"
      end

      # On Snow Leopard and older system libc++abi is not shipped but
      # needed here. It is hard to tweak environment settings to change
      # include path as libc++ uses a custom build script, so just
      # symlink the needed header here.
      ln_s libcxxabi_buildpath/"include/cxxabi.h", libcxx_buildpath/"include"
    end

    # Putting libcxx in projects only ensures that headers are installed.
    # Manually "make install" to actually install the shared libs.
    libcxx_make_args = [
      # Use the built clang for building
      "CC=#{install_prefix}/bin/clang",
      "CXX=#{install_prefix}/bin/clang++",
      # Properly set deployment target, which is needed for Snow Leopard
      "MACOSX_DEPLOYMENT_TARGET=#{MacOS.version}",
      # The following flags are needed so it can be installed correctly.
      "DSTROOT=#{install_prefix}",
      "SYMROOT=#{libcxx_buildpath}",
    ]

    system "make", "-C", libcxx_buildpath, "install", *libcxx_make_args

    (share/"clang-#{ver}/tools").install Dir["tools/clang/tools/scan-{build,view}"]

    (lib/"python2.7/site-packages").install "bindings/python/llvm" => "llvm-#{ver}",
                                            clang_buildpath/"bindings/python/clang" => "clang-#{ver}"
    (lib/"python2.7/site-packages").install_symlink install_prefix/"lib/python2.7/site-packages/lldb" => "lldb-#{ver}" if build.with? "lldb"

    Dir.glob(install_prefix/"bin/*") do |exec_path|
      basename = File.basename(exec_path)
      bin.install_symlink exec_path => "#{basename}-#{ver}"
    end

    Dir.glob(install_prefix/"share/man/man1/*") do |manpage|
      basename = File.basename(manpage, ".1")
      man1.install_symlink manpage => "#{basename}-#{ver}.1"
    end
  end

  def caveats; <<-EOS.undent
    Extra tools are installed in #{opt_share}/clang-#{ver}

    To link to libc++, something like the following is required:
      CXX="clang++-#{ver} -stdlib=libc++"
      CXXFLAGS="$CXXFLAGS -nostdinc++ -I#{opt_lib}/llvm-#{ver}/include/c++/v1"
      LDFLAGS="$LDFLAGS -L#{opt_lib}/llvm-#{ver}/lib"
    EOS
  end

  test do
    system "#{bin}/llvm-config-#{ver}", "--version"
  end
end

__END__
diff --git a/Makefile.rules b/Makefile.rules
index ebebc0a..b0bb378 100644
--- a/Makefile.rules
+++ b/Makefile.rules
@@ -599,7 +599,12 @@ ifneq ($(HOST_OS), $(filter $(HOST_OS), Cygwin MingW))
 ifneq ($(HOST_OS),Darwin)
   LD.Flags += $(RPATH) -Wl,'$$ORIGIN'
 else
-  LD.Flags += -Wl,-install_name  -Wl,"@rpath/lib$(LIBRARYNAME)$(SHLIBEXT)"
+  LD.Flags += -Wl,-install_name
+  ifdef LOADABLE_MODULE
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(LIBRARYNAME)$(SHLIBEXT)"
+  else
+    LD.Flags += -Wl,"$(PROJ_libdir)/$(SharedPrefix)$(LIBRARYNAME)$(SHLIBEXT)"
+  endif
 endif
 endif
 endif
