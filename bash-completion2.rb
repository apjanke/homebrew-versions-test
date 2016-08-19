class BashCompletion2 < Formula
  desc "Programmable completion for Bash 4.0+"
  homepage "https://github.com/scop/bash-completion"
  url "https://github.com/scop/bash-completion/releases/download/2.3/bash-completion-2.3.tar.xz"
  sha256 "b2e081af317f3da4fff3a332bfdbebeb5514ebc6c2d2a9cf781180acab15e8e9"
  head "https://github.com/scop/bash-completion.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "d09547e2899fa8ebb91737a60fbb67d5fa0f7b4bab5c15b50c4cfacb533974e9" => :el_capitan
    sha256 "bf5de0393acf3041e2801981017f53a62cb2d34435e63519ef352f507f26d361" => :yosemite
    sha256 "3f7d127ea60af0e26d4c5b0621b3eeabe4550d49a59411e72ff3a03e28cd05b7" => :mavericks
  end

  conflicts_with "bash-completion"

  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=739835
  # resolves issue with completion of files/directories with spaces in the name.
  patch do
    url "https://anonscm.debian.org/cgit/bash-completion/debian.git/plain/debian/patches/00-fix_quote_readline_by_ref.patch?id=d734ca3bd73ae49b8f452802fb8fb65a440ab07a"
    sha256 "7304f8fb4ad869f1b3d6f3456b2750246ddedef6fc307939bf403bf528f2fdf1"
  end

  def install
    inreplace "bash_completion", "readlink -f", "readlink"

    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    ENV.deparallelize
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    Add the following to your ~/.bash_profile:
      if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
        . $(brew --prefix)/share/bash-completion/bash_completion
      fi
    EOS
  end

  test do
    system "test", "-f", "#{share}/bash-completion/bash_completion"
  end
end
