class Ruby186 < Formula
  desc "Powerful, clean, object-oriented scripting language"
  homepage "https://www.ruby-lang.org/"
  url "http://cache.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6-p420.tar.bz2"
  sha256 "5ed3e6b9ebcb51baf59b8263788ec9ec8a65fbb82286d952dd3eb66e22d9a09f"
  revision 1

  bottle do
    sha256 "e1c95c51e9e6bded398ddbdf005eb11546a030281bcadf2d921bd816dea96c55" => :yosemite
    sha256 "ca1bff8acfd1da8f093c2f4bdd0ebe7655ce485c6bffd0b069417497b2f739ae" => :mavericks
    sha256 "29cb67a3e824144a4e16304c4d84eed4ea4032b0ee24a130ff28a259556f2e81" => :mountain_lion
  end

  # Otherwise it fails when building bigdecimal by trying to load
  # files from the system ruby instead of the one it's building
  env :std

  keg_only :provided_by_osx

  option :universal
  option "with-suffix", "Suffix commands with '186'"
  option "with-doc", "Install documentation"
  option "with-tcltk", "Install with Tcl/Tk support"

  depends_on "pkg-config" => :build
  depends_on "readline" => :recommended
  depends_on "gdbm" => :optional
  depends_on "libyaml"
  depends_on "openssl" if MacOS.version >= :mountain_lion
  depends_on :x11 if build.with? "tcltk"

  fails_with :llvm do
    build 2326
  end

  # First patch backports a compatibility fix from Ruby 1.8.7 for newer OpenSSL versions
  # Second patch fixes the type of a macro, also taken from 1.8.7
  # Third patch fixes another OpenSSL macro, taken from Ruby 2.1.4
  patch :DATA

  def install
    ENV.deparallelize

    args = %W[--prefix=#{prefix} --enable-shared]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=186" if build.with? "suffix"
    args << "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?

    # Put gem, site and vendor folders in the HOMEBREW_PREFIX
    ruby_lib = HOMEBREW_PREFIX/"lib/ruby"
    (ruby_lib/"site_ruby").mkpath
    (ruby_lib/"vendor_ruby").mkpath
    (ruby_lib/"gems").mkpath

    (lib/"ruby").install_symlink ruby_lib/"site_ruby",
                                 ruby_lib/"vendor_ruby",
                                 ruby_lib/"gems"

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end

  test do
    output = `#{bin}/ruby -e "puts 'hello'"`
    assert_equal "hello\n", output
    assert_equal 0, $?.exitstatus
  end
end

__END__
diff --git a/ext/openssl/ossl.h b/ext/openssl/ossl.h
index 8dfd8da..25a62bc 100644
--- a/ext/openssl/ossl.h
+++ b/ext/openssl/ossl.h
@@ -107,6 +107,13 @@ extern VALUE eOSSLError;
 } while (0)
 
 /*
+* Compatibility
+*/
+#if OPENSSL_VERSION_NUMBER >= 0x10000000L
+#define STACK _STACK
+#endif
+
+/*
  * String to HEXString conversion
  */
 int string2hex(char *, int, char **, int *);

diff --git a/ext/openssl/ossl.c b/ext/openssl/ossl.c
index 1b8f76a..73fdd03 100644
--- a/ext/openssl/ossl.c
+++ b/ext/openssl/ossl.c
@@ -92,7 +92,7 @@ ossl_x509_ary2sk(VALUE ary)
 
 #define OSSL_IMPL_SK2ARY(name, type)	        \
 VALUE						\
-ossl_##name##_sk2ary(STACK *sk)			\
+ossl_##name##_sk2ary(STACK_OF(type) *sk)			\
 {						\
     type *t;					\
     int i, num;					\

diff --git a/ext/openssl/ossl_ssl.c b/ext/openssl/ossl_ssl.c
index c4569c7..d6f8822 100644
--- a/ext/openssl/ossl_ssl.c
+++ b/ext/openssl/ossl_ssl.c
@@ -96,13 +96,16 @@ struct {
     const char *name;
     SSL_METHOD *(*func)(void);
 } ossl_ssl_method_tab[] = {
-#define OSSL_SSL_METHOD_ENTRY(name) { #name, name##_method }
+#define OSSL_SSL_METHOD_ENTRY(name) { #name, (SSL_METHOD *(*)(void))name##_method }
     OSSL_SSL_METHOD_ENTRY(TLSv1),
     OSSL_SSL_METHOD_ENTRY(TLSv1_server),
     OSSL_SSL_METHOD_ENTRY(TLSv1_client),
+#if defined(HAVE_SSLV2_METHOD) && defined(HAVE_SSLV2_SERVER_METHOD) && \
+        defined(HAVE_SSLV2_CLIENT_METHOD)
     OSSL_SSL_METHOD_ENTRY(SSLv2),
     OSSL_SSL_METHOD_ENTRY(SSLv2_server),
     OSSL_SSL_METHOD_ENTRY(SSLv2_client),
+#endif
     OSSL_SSL_METHOD_ENTRY(SSLv3),
     OSSL_SSL_METHOD_ENTRY(SSLv3_server),
     OSSL_SSL_METHOD_ENTRY(SSLv3_client),
