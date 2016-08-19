class Hive011 < Formula
  desc "Hadoop-based data summarization, query, and analysis"
  homepage "https://hive.apache.org"
  url "https://archive.apache.org/dist/hive/hive-0.11.0/hive-0.11.0-bin.tar.gz"
  sha256 "c22ee328438e80a8ee4b66979dba69650511a73f8b6edf2d87d93c74283578e5"

  depends_on "hadoop"
  depends_on :java

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[bin conf examples lib]
    libexec.install Dir["*.jar"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  def caveats; <<-EOS.undent
    Hadoop must be in your path for hive executable to work.
    After installation, set $HIVE_HOME in your profile:
      export HIVE_HOME=#{libexec}

    You may need to set JAVA_HOME:
      export JAVA_HOME="$(/usr/libexec/java_home)"
    EOS
  end
end
