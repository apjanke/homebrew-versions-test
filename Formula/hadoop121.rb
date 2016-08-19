class Hadoop121 < Formula
  desc "Framework for distributed processing of large data sets"
  homepage "https://hadoop.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=hadoop/core/hadoop-1.2.1/hadoop-1.2.1.tar.gz"
  sha256 "94a1181771f173bdb55c8f901722825866396091f0516bdd12b34dc3de1706a1"

  keg_only "Conflicts with hadoop in core."

  depends_on :java

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[bin conf lib webapps contrib]
    libexec.install Dir["*.jar"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
    # But don't make rcc visible, it conflicts with Qt
    (bin/"rcc").unlink

    inreplace "#{libexec}/conf/hadoop-env.sh",
      "# export JAVA_HOME=/usr/lib/j2sdk1.5-sun",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
  end

  def caveats; <<-EOS.undent
    In Hadoop's config file:
      #{libexec}/conf/hadoop-env.sh
    $JAVA_HOME has been set to be the output of:
      /usr/libexec/java_home
    EOS
  end
end
