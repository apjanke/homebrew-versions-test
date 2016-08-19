class Drush4 < Formula
  homepage "https://github.com/drush-ops/drush"
  url "http://ftp.drupal.org/files/projects/drush-7.x-4.6.tar.gz"
  sha256 "c8f5a165c1624b023aaa74b4fd852da1dc426bd08f7cf1af328fe16e7de27d8d"

  bottle :unneeded

  keg_only "Conflicts with drush in main repository."

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec+"drush"
  end
end
