class Iojs < Formula
  desc "npm-compatible platform based on Node.js"
  homepage "https://iojs.org/"
  url "https://iojs.org/dist/v3.3.1/iojs-v3.3.1.tar.xz"
  sha256 "c5b1a7117b75dca563f66c35ee65db6fc43e25a3756608ad2c4d60087314bd36"

  bottle do
    sha256 "8bad3933f41c806ff0c9a8a0bae3c07bcac4401cc0bf4c22d27f2eaac461bec3" => :el_capitan
    sha256 "cecbb6ffd64df4a41e41c45ca40fbf5e2b69803eb0e78307b5443a4264d39bbf" => :yosemite
    sha256 "334e1ac9b248c15918562b03bec52b1829eb99afed4e1eb9324238712f20d9f6" => :mavericks
  end

  option "with-debug", "Build with debugger hooks"
  option "without-npm", "npm will not be installed"
  option "without-completion", "npm bash completion will not be installed"
  option "with-full-icu", "Build with full-icu (all locales) instead of small-icu (English only)"

  depends_on "pkg-config" => :build
  depends_on "openssl" => :optional
  depends_on :python => :build if MacOS.version <= :snow_leopard

  conflicts_with "node", :because => "Differing release line of the node formula"

  fails_with :llvm do
    build 2326
  end

  resource "npm" do
    url "https://registry.npmjs.org/npm/-/npm-2.14.4.tgz"
    sha256 "c8b602de5d51f956aa8f9c34d89be38b2df3b7c25ff6588030eb8224b070db27"
  end

  resource "icu4c" do
    url "https://ssl.icu-project.org/files/icu4c/55.1/icu4c-55_1-src.tgz"
    mirror "https://fossies.org/linux/misc/icu4c-55_1-src.tgz"
    version "55.1"
    sha256 "e16b22cbefdd354bec114541f7849a12f8fc2015320ca5282ee4fd787571457b"
  end

  def install
    args = %W[--prefix=#{prefix} --without-npm]
    args << "--debug" if build.with? "debug"
    args << "--shared-openssl" if build.with? "openssl"
    if build.with? "full-icu"
      args << "--with-intl=full-icu"
    else
      args << "--with-intl=small-icu"
    end

    resource("icu4c").stage buildpath/"deps/icu"

    system "./configure", *args
    system "make", "install"

    if build.with? "npm"
      resource("npm").stage buildpath/"npm_install"

      # make sure npm can find node
      ENV.prepend_path "PATH", bin
      # set log level temporarily for npm's `make install`
      ENV["NPM_CONFIG_LOGLEVEL"] = "verbose"

      cd buildpath/"npm_install" do
        system "./configure", "--prefix=#{libexec}/npm"
        system "make", "install"
      end

      if build.with? "completion"
        bash_completion.install \
          buildpath/"npm_install/lib/utils/completion.sh" => "npm"
      end
    end
  end

  def post_install
    return if build.without? "npm"

    node_modules = HOMEBREW_PREFIX/"lib/node_modules"
    node_modules.mkpath
    npm_exec = node_modules/"npm/bin/npm-cli.js"
    # Kill npm but preserve all other modules across node updates/upgrades.
    rm_rf node_modules/"npm"

    cp_r libexec/"npm/lib/node_modules/npm", node_modules
    # This symlink doesn't hop into homebrew_prefix/bin automatically so
    # remove it and make our own. This is a small consequence of our bottle
    # npm make install workaround. All other installs **do** symlink to
    # homebrew_prefix/bin correctly. We ln rather than cp this because doing
    # so mimics npm's normal install.
    ln_sf npm_exec, "#{HOMEBREW_PREFIX}/bin/npm"

    # Let's do the manpage dance. It's just a jump to the left.
    # And then a step to the right, with your hand on rm_f.
    ["man1", "man3", "man5", "man7"].each do |man|
      # Dirs must exist first: https://github.com/Homebrew/homebrew/issues/35969
      mkdir_p HOMEBREW_PREFIX/"share/man/#{man}"
      rm_f Dir[HOMEBREW_PREFIX/"share/man/#{man}/{npm.,npm-,npmrc.}*"]
      ln_sf Dir[libexec/"npm/lib/node_modules/npm/man/#{man}/npm*"], HOMEBREW_PREFIX/"share/man/#{man}"
    end

    npm_root = node_modules/"npm"
    npmrc = npm_root/"npmrc"
    npmrc.atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  def caveats
    s = ""

    if build.without? "npm"
      s += <<-EOS.undent
        Homebrew has NOT installed npm. If you later install it, you should supplement
        your NODE_PATH with the npm module folder:
          #{HOMEBREW_PREFIX}/lib/node_modules
      EOS
    end

    s
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = `#{bin}/iojs #{path}`.strip
    assert_equal "hello", output
    assert_equal 0, $?.exitstatus
    output = `#{bin}/iojs -e "console.log(new Date('2015-09-15').toLocaleDateString('en'))"`.strip
    assert_match %r{^9/1[45]/2015$}, output # depends on system timezone
    assert_equal 0, $?.exitstatus

    if build.with? "npm"
      # make sure npm can find node
      ENV.prepend_path "PATH", opt_bin
      assert_equal which("node"), opt_bin/"node"
      assert (HOMEBREW_PREFIX/"bin/npm").exist?, "npm must exist"
      assert (HOMEBREW_PREFIX/"bin/npm").executable?, "npm must be executable"
      system "#{HOMEBREW_PREFIX}/bin/npm", "--verbose", "install", "npm@latest"
      system "#{HOMEBREW_PREFIX}/bin/npm", "--verbose", "install", "bignum"
    end
  end
end
