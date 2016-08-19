class Perl516 < Formula
  desc "Highly capable, feature-rich programming language"
  homepage "https://www.perl.org/"
  url "http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz"
  sha256 "69cf08dca0565cec2c5c6c2f24b87f986220462556376275e5431cc2204dedb6"

  bottle do
    sha256 "371522e97d37ab23326a0e17786886852dcf44d98b44262fa6bb5caa0531db36" => :yosemite
    sha256 "ae94017d2adf64ce4f58e61d5c00827cacb4541f2bf9787a8a8ecd633bd0bec1" => :mavericks
    sha256 "a0fed2164f7b3718614564d7646505c3235268cc76b691506ea98426959bb9ed" => :mountain_lion
  end

  keg_only :provided_by_osx,
    "OS X ships Perl and overriding that can cause unintended issues"

  option "with-dtrace", "Build with DTrace probes"
  option "with-tests", "Build and run the test suite"

  deprecated_option "use-dtrace" => "with-dtrace"

  def install
    args = [
      "-des",
      "-Dprefix=#{prefix}",
      "-Dman1dir=#{man1}",
      "-Dman3dir=#{man3}",
      "-Duseshrplib",
      "-Duselargefiles",
      "-Dusethreads",
    ]

    args << "-Dusedtrace" if build.with? "dtrace"

    system "./Configure", *args
    system "make"
    system "make", "test" if build.with? "tests"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    By default Perl installs modules in your HOME dir. If this is an issue run:
      #{bin}/cpan o conf init
    EOS
  end

  test do
    (testpath/"test.pl").write "print 'Perl is not an acronym, but JAPH is a Perl acronym!';"
    system "#{bin}/perl", "test.pl"
  end
end
