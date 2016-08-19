class Ruby192 < Formula
  desc "Powerful, clean, object-oriented scripting language"
  homepage "http://www.ruby-lang.org/en/"
  url "http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p330.tar.bz2"
  sha256 "6d3487ea8a86ad0fa78a8535078ff3c7a91ca9f99eff0a6a08e66c6e6bf2040f"

  depends_on "pkg-config" => :build
  depends_on "readline"
  depends_on "gdbm"
  depends_on "libyaml"

  option :universal
  option "with-suffix", 'Suffix commands with "192"'
  option "with-doc", "Install documentation"

  fails_with :llvm do
    build 2326
  end

  def install
    args = %W[--prefix=#{prefix} --enable-shared]

    if build.universal?
      ENV.universal_binary
      args << "--with-arch=#{Hardware::CPU.universal_archs.join(",")}"
    end

    args << "--program-suffix=192" if build.with? "suffix"

    system "./configure", *args
    system "make"
    system "make", "install"
    system "make install-doc" if build.with? "doc"
  end

  def post_install
    (lib/"ruby/#{abi_version}/rubygems/defaults/operating_system.rb").write rubygems_config
  end

  def abi_version
    "1.9.1"
  end

  def rubygems_config; <<-EOS.undent
    module Gem
      class << self
        alias :old_default_dir :default_dir
        alias :old_default_path :default_path
        alias :old_default_bindir :default_bindir
        alias :old_ruby :ruby
      end

      def self.default_dir
        path = [
          "#{HOMEBREW_PREFIX}",
          "lib",
          "ruby",
          "gems",
          "#{abi_version}"
        ]

        @default_dir ||= File.join(*path)
      end

      def self.private_dir
        path = if defined? RUBY_FRAMEWORK_VERSION then
                 [
                   File.dirname(RbConfig::CONFIG['sitedir']),
                   'Gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               elsif RbConfig::CONFIG['rubylibprefix'] then
                 [
                  RbConfig::CONFIG['rubylibprefix'],
                  'gems',
                  RbConfig::CONFIG['ruby_version']
                 ]
               else
                 [
                   RbConfig::CONFIG['libdir'],
                   ruby_engine,
                   'gems',
                   RbConfig::CONFIG['ruby_version']
                 ]
               end

        @private_dir ||= File.join(*path)
      end

      def self.default_path
        if Gem.user_home && File.exist?(Gem.user_home)
          [user_dir, default_dir, private_dir]
        else
          [default_dir, private_dir]
        end
      end

      def self.default_bindir
        "#{HOMEBREW_PREFIX}/bin"
      end

      def self.ruby
        "#{opt_bin}/ruby#{"192" if build.with? "suffix"}"
      end
    end
    EOS
  end
end
