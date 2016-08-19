class CodesignRequirement < Requirement
  include FileUtils
  fatal true

  satisfy(:build_env => false) do
    mktemp do
      cp "/usr/bin/false", "llvm_check"
      quiet_system "/usr/bin/codesign", "-f", "-s", "lldb_codesign", "--dryrun", "llvm_check"
    end
  end

  def message
    <<-EOS.undent
      lldb_codesign identity must be available to build with LLDB.
      See: https://llvm.org/svn/llvm-project/lldb/trunk/docs/code-signing.txt
    EOS
  end
end

class Llvm36 < Formula
  desc "Modular and reusable compiler system"
  homepage "http://llvm.org/"

  stable do
    url "http://llvm.org/releases/3.6.2/llvm-3.6.2.src.tar.xz"
    sha256 "f60dc158bfda6822de167e87275848969f0558b3134892ff54fced87e4667b94"

    resource "clang" do
      url "http://llvm.org/releases/3.6.2/cfe-3.6.2.src.tar.xz"
      sha256 "ae9180466a23acb426d12444d866b266ff2289b266064d362462e44f8d4699f3"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/releases/3.6.2/clang-tools-extra-3.6.2.src.tar.xz"
      sha256 "6a0ec627d398f501ddf347060f7a2ccea4802b2494f1d4fd7bda3e0442d04feb"
    end

    resource "compiler-rt" do
      url "http://llvm.org/releases/3.6.2/compiler-rt-3.6.2.src.tar.xz"
      sha256 "0f2ff37d80a64575fecd8cf0d5c50f7ac1f837ddf700d1855412bb7547431d87"
    end

    resource "polly" do
      url "http://llvm.org/releases/3.6.2/polly-3.6.2.src.tar.xz"
      sha256 "f2a956730b76212f22a1c10f35f195795e4d027ad28c226f97ddb8c0fd16bcbc"
    end

    resource "lld" do
      url "http://llvm.org/releases/3.6.2/lld-3.6.2.src.tar.xz"
      sha256 "43f553c115563600577764262f1f2fac3740f0c639750f81e125963c90030b33"
    end

    resource "lldb" do
      url "http://llvm.org/releases/3.6.2/lldb-3.6.2.src.tar.xz"
      sha256 "940dc96b64919b7dbf32c37e0e1d1fc88cc18e1d4b3acf1e7dfe5a46eb6523a9"
    end

    resource "libcxx" do
      url "http://llvm.org/releases/3.6.2/libcxx-3.6.2.src.tar.xz"
      sha256 "52f3d452f48209c9df1792158fdbd7f3e98ed9bca8ebb51fcd524f67437c8b81"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/releases/3.6.2/libcxxabi-3.6.2.src.tar.xz"
        sha256 "6fb48ce5a514686b9b75e73e59869f782ed374a86d71be8423372e4b3329b09b"
      end
    end
  end

  bottle do
    revision 1
    sha256 "6f30868fbf5b515118f5f856381ad093adf7f7caac3b2deb21441e71c12c98c8" => :el_capitan
    sha256 "09504fc4a73dc6524ba5c8d3ac9f87bc07595203f7c49126808183f184275cab" => :yosemite
    sha256 "6965cd67562a7b24fccc1d9baefc4f6f5656220d43ffbf86d2b50886c2cd807d" => :mavericks
  end

  head do
    url "http://llvm.org/git/llvm.git", :branch => "release_36"

    resource "clang" do
      url "http://llvm.org/git/clang.git", :branch => "release_36"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/git/clang-tools-extra.git", :branch => "release_36"
    end

    resource "compiler-rt" do
      url "http://llvm.org/git/compiler-rt.git", :branch => "release_36"
    end

    resource "polly" do
      url "http://llvm.org/git/polly.git", :branch => "release_36"
    end

    resource "lld" do
      url "http://llvm.org/git/lld.git", :branch => "release_36"
    end

    resource "lldb" do
      url "http://llvm.org/git/lldb.git", :branch => "release_36"
    end

    resource "libcxx" do
      url "http://llvm.org/git/libcxx.git", :branch => "release_36"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/git/libcxxabi.git", :branch => "release_36"
      end
    end
  end

  option :universal
  option "with-lld", "Build LLD linker"
  option "with-lldb", "Build LLDB debugger"
  option "with-asan", "Include support for -faddress-sanitizer (from compiler-rt)"
  option "with-all-targets", "Build all target backends"
  option "with-python", "Build lldb bindings against the python in PATH instead of system Python"
  option "without-shared", "Don't build LLVM as a shared library"
  option "without-assertions", "Speeds up LLVM, but provides less debug information"

  # required to build isl
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build

  depends_on "gmp"
  depends_on "libffi" => :recommended
  depends_on :python => :optional

  if build.with? "lldb"
    depends_on "swig"
    depends_on CodesignRequirement
  end

  resource "isl" do
    url "http://isl.gforge.inria.fr/isl-0.14.1.tar.gz"
    sha256 "bd15d06d050a92a6720fc7e2a58022a3fd1a73c4996cc358ba50864fd5e86c35"
  end

  patch :DATA

  # version suffix
  def ver
    "3.6"
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

    resource("isl").stage do
      system "./configure", "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{isl_prefix}",
                            "--with-gmp=system",
                            "--with-gmp-prefix=#{gmp_prefix}"
      system "make"
      system "make", "install"
    end

    args = [
      "--prefix=#{install_prefix}",
      "--enable-optimized",
      "--disable-bindings",
      "--with-gmp=#{gmp_prefix}",
      "--with-isl=#{isl_prefix}",
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
    inreplace share/"clang-#{ver}/tools/scan-build/scan-build", "$RealBin/bin/clang", install_prefix/"bin/clang"
    ln_s share/"clang-#{ver}/tools/scan-build/scan-build", install_prefix/"bin"
    ln_s share/"clang-#{ver}/tools/scan-view/scan-view", install_prefix/"bin"
    (install_prefix/"share/man/man1").install share/"clang-#{ver}/tools/scan-build/scan-build.1"

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
