class Tomcat7 < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.70/bin/apache-tomcat-7.0.70.tar.gz"
  sha256 "13f33616a3352e4fce548e042adfdd824353d0b48a42e1606daace7916868c74"

  bottle :unneeded

  conflicts_with "tomcat", :because => "Differing versions of same formula"

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.70/bin/apache-tomcat-7.0.70-fulldocs.tar.gz"
    version "7.0.70"
    sha256 "5666f430c1234dec5319b481aaab22f22bb56a5a8a0c00a3aba3d310171e1e25"
  end

  # Keep log folders
  skip_clean "libexec"

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w[NOTICE LICENSE RELEASE-NOTES RUNNING.txt]
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end
end
