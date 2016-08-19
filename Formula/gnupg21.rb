class Gnupg21 < Formula
  desc "GNU Privacy Guard: a free PGP replacement"
  homepage "https://www.gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.1.13.tar.bz2"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnupg/gnupg-2.1.13.tar.bz2"
  sha256 "4f9d83a6221daa60130fa79f0b1d37d6c20fffdd0320b640c7a597c5b6219675"

  bottle do
    sha256 "4badc6179f850d075d1068e1b5dd2cb9e8c57a58f1a21ffc561aa755bfddf945" => :el_capitan
    sha256 "731f538bb306ca1d27d50a73adad5abd4242fb21eff13012a0d1a687fc489b92" => :yosemite
    sha256 "e759f7df6242fd5f25bb18e7c9daa880cfb6f56bcddc067ff37dfbf1d5f65e0d" => :mavericks
  end

  head do
    url "git://git.gnupg.org/gnupg.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-gpgsplit", "Additionally install the gpgsplit utility"

  depends_on "pkg-config" => :build
  depends_on "sqlite" => :build if MacOS.version == :mavericks
  depends_on "npth"
  depends_on "gnutls"
  depends_on "libgpg-error"
  depends_on "libgcrypt"
  depends_on "libksba"
  depends_on "libassuan"
  depends_on "pinentry"
  depends_on "gettext"
  depends_on "adns"
  depends_on "libusb-compat" => :recommended
  depends_on "readline" => :optional
  depends_on "homebrew/fuse/encfs" => :optional

  conflicts_with "gnupg2",
        :because => "GPG2.1.x is incompatible with the 2.0.x branch."
  conflicts_with "gpg-agent",
        :because => "GPG2.1.x ships an internal gpg-agent which it must use."
  conflicts_with "dirmngr",
        :because => "GPG2.1.x ships an internal dirmngr which it it must use."
  conflicts_with "fwknop",
        :because => "fwknop expects to use a `gpgme` with Homebrew/Homebrew's gnupg2."
  conflicts_with "gpgme",
        :because => "gpgme currently requires 1.x.x or 2.0.x."

  # Patch for `make check` failures in 2.1.13.
  # Fixed upstream by Justus Winter & can be removed in next release.
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/7b2211b/gnupg21/spawned_child_8f79c31b.diff"
    sha256 "fde57b1e484aa738af8f582910330cadef144430d9221d3242b5f635c7f41dbe"
  end

  def install
    (var/"run").mkpath

    ENV.append "LDFLAGS", "-lresolv"
    ENV["gl_cv_absolute_stdint_h"] = "#{MacOS.sdk_path}/usr/include/stdint.h"

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sbindir=#{bin}
      --sysconfdir=#{etc}
      --enable-symcryptrun
      --with-pinentry-pgm=#{Formula["pinentry"].opt_bin}/pinentry
    ]

    args << "--with-readline=#{Formula["readline"].opt_prefix}" if build.with? "readline"

    if build.head?
      args << "--enable-maintainer-mode"
      system "./autogen.sh", "--force"
      system "automake", "--add-missing"
    end

    # Adjust package name to fit our scheme of packaging both gnupg 1.x and
    # and 2.1.x and gpg-agent separately.
    inreplace "configure" do |s|
      s.gsub! "PACKAGE_NAME='gnupg'", "PACKAGE_NAME='gnupg2'"
      s.gsub! "PACKAGE_TARNAME='gnupg'", "PACKAGE_TARNAME='gnupg2'"
    end

    system "./configure", *args

    system "make"
    system "make", "check"
    system "make", "install"

    bin.install "tools/gpgsplit" => "gpgsplit2" if build.with? "gpgsplit"

    # Move man files that conflict with 1.x.
    mv share/"doc/gnupg2/FAQ", share/"doc/gnupg2/FAQ21"
    mv share/"doc/gnupg2/examples/gpgconf.conf", share/"doc/gnupg2/examples/gpgconf21.conf"
    mv share/"info/gnupg.info", share/"info/gnupg21.info"
    mv man7/"gnupg.7", man7/"gnupg21.7"
  end

  def caveats; <<-EOS.undent
    Once you run the new gpg2 binary you will find it incredibly
    difficult to go back to using `gnupg2` from Homebrew/Homebrew.
    The new 2.1.x moves to a new keychain format that can't be
    and won't be understood by the 2.0.x branch or lower.

    If you use this `gnupg21` formula for a while and decide
    you don't like it, you will lose the keys you've imported since.
    For this reason, we strongly advise that you make a backup
    of your `~/.gnupg` directory.

    For full details of the changes, please visit:
      https://www.gnupg.org/faq/whats-new-in-2.1.html

    If you are upgrading to gnupg21 from gnupg2 you should execute:
      `killall gpg-agent && gpg-agent --daemon`
    After install. See:
      https://github.com/Homebrew/homebrew-versions/issues/681
    EOS
  end

  test do
    system "#{bin}/gpgconf"
  end
end
