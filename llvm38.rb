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

class Llvm38 < Formula
  desc "The LLVM Compiler Infrastructure"
  homepage "http://llvm.org/"

  stable do
    url "http://llvm.org/releases/3.8.0/llvm-3.8.0.src.tar.xz"
    sha256 "555b028e9ee0f6445ff8f949ea10e9cd8be0d084840e21fbbe1d31d51fc06e46"

    resource "clang" do
      url "http://llvm.org/releases/3.8.0/cfe-3.8.0.src.tar.xz"
      sha256 "04149236de03cf05232d68eb7cb9c50f03062e339b68f4f8a03b650a11536cf9"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/releases/3.8.0/clang-tools-extra-3.8.0.src.tar.xz"
      sha256 "afbda810106a6e64444bc164b921be928af46829117c95b996f2678ce4cb1ec4"
    end

    resource "compiler-rt" do
      url "http://llvm.org/releases/3.8.0/compiler-rt-3.8.0.src.tar.xz"
      sha256 "c8d3387e55f229543dac1941769120f24dc50183150bf19d1b070d53d29d56b0"
    end

    resource "polly" do
      url "http://llvm.org/releases/3.8.0/polly-3.8.0.src.tar.xz"
      sha256 "84cbabc0b6a10a664797907d291b6955d5ea61aef04e3f3bb464e42374d1d1f2"
    end

    resource "lld" do
      url "http://llvm.org/releases/3.8.0/lld-3.8.0.src.tar.xz"
      sha256 "94704dda228c9f75f4403051085001440b458501ec97192eee06e8e67f7f9f0c"
    end

    resource "lldb" do
      url "http://llvm.org/releases/3.8.0/lldb-3.8.0.src.tar.xz"
      sha256 "e3f68f44147df0433e7989bf6ed1c58ff28d7c68b9c47553cb9915f744785a35"
    end

    resource "libcxx" do
      url "http://llvm.org/releases/3.8.0/libcxx-3.8.0.src.tar.xz"
      sha256 "36804511b940bc8a7cefc7cb391a6b28f5e3f53f6372965642020db91174237b"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/releases/3.8.0/libcxxabi-3.8.0.src.tar.xz"
        sha256 "c5ee0871aff6ec741380c4899007a7d97f0b791c81df69d25b744eebc5cee504"
      end
    end
  end
  bottle do
    sha256 "d11c8af13e3560b99da7444ea4b98766aca1c2cde2c4d7d9d70450769f80106d" => :el_capitan
    sha256 "992e53288649668ce8125a0fda5b4e96c0e33871b377087c582f55a055f8bc1c" => :yosemite
    sha256 "aaca71557a11144d9fb8276f791282c910f7172dbbe7a6f63a146d718d058b16" => :mavericks
  end

  head do
    url "http://llvm.org/git/llvm.git", :branch => "release_38"

    resource "clang" do
      url "http://llvm.org/git/clang.git", :branch => "release_38"
    end

    resource "clang-tools-extra" do
      url "http://llvm.org/git/clang-tools-extra.git", :branch => "release_38"
    end

    resource "compiler-rt" do
      url "http://llvm.org/git/compiler-rt.git", :branch => "release_38"
    end

    resource "polly" do
      url "http://llvm.org/git/polly.git", :branch => "release_38"
    end

    resource "lld" do
      url "http://llvm.org/git/lld.git"
    end

    resource "lldb" do
      url "http://llvm.org/git/lldb.git", :branch => "release_38"
    end

    resource "libcxx" do
      url "http://llvm.org/git/libcxx.git", :branch => "release_38"
    end

    if MacOS.version <= :snow_leopard
      resource "libcxxabi" do
        url "http://llvm.org/git/libcxxabi.git", :branch => "release_38"
      end
    end
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

  depends_on "gnu-sed" => :build
  depends_on "gmp"
  depends_on "libffi" => :recommended
  depends_on :python => :optional

  if build.with? "lldb"
    depends_on "swig"
    depends_on CodesignRequirement
  end

  # version suffix
  def ver
    "3.8"
  end

  # LLVM installs its own standard library which confuses stdlib checking.
  cxxstdlib_check :skip

  # Apple's libstdc++ is too old to build LLVM
  fails_with :gcc
  fails_with :llvm

  def install
    # One of llvm makefiles relies on gnu sed behavior to generate CMake modules correctly
    ENV.prepend_path "PATH", "#{Formula["gnu-sed"].opt_libexec}/gnubin"
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

    args = %W[
      --prefix=#{install_prefix}
      --enable-optimized
      --disable-bindings
      --with-gmp=#{Formula["gmp"].opt_prefix}
    ]

    if build.with? "all-targets"
      args << "--enable-targets=all"
    else
      args << "--enable-targets=host"
    end

    args << "--enable-shared" if build.with? "shared"
    args << "--disable-assertions" if build.without? "assertions"
    args << "--enable-libffi" if build.with? "libffi"

    mktemp do
      system buildpath/"configure", *args
      system "make", "VERBOSE=1", "install"
    end

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

    (share/"clang/tools").install Dir["tools/clang/tools/scan-{build,view}"]
    inreplace share/"clang/tools/scan-build/bin/scan-build", "$RealBin/bin/clang", bin/"clang-#{ver}"
    bin.install_symlink share/"clang/tools/scan-build/bin/scan-build", share/"clang/tools/scan-view/bin/scan-view"
    man1.install_symlink share/"clang/tools/scan-build/man/scan-build.1"

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
    # test for sed errors since some llvm makefiles assume that sed
    # understands '\n' which is true for gnu sed and not for bsd sed.
    assert_no_match /PATH\)n/, (lib/"llvm-3.8/share/llvm/cmake/LLVMConfig.cmake").read
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
