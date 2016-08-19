class Clojure14 < Formula
  homepage "http://clojure.org/"
  url "http://repo1.maven.org/maven2/org/clojure/clojure/1.4.0/clojure-1.4.0.zip"
  sha256 "27a5a151d5cc1bc3e52dff47c66111e637fefeb42d9bedfa1284a1a31d080171"

  bottle :unneeded

  def script; <<-EOS.undent
    #!/bin/sh
    # Clojure wrapper script.
    # With no arguments runs Clojure's REPL.

    # Put the Clojure jar from the cellar and the current folder in the classpath.
    CLOJURE=$CLASSPATH:#{prefix}/#{jar}:${PWD}

    if [ "$#" -eq 0 ]; then
        java -cp "$CLOJURE" clojure.main --repl
    else
        java -cp "$CLOJURE" clojure.main "$@"
    fi
    EOS
  end

  def jar
    "clojure-#{version}.jar"
  end

  def install
    prefix.install jar
    (prefix+jar).chmod(0644) # otherwise it's 0600
    (prefix+"classes").mkpath
    (bin+"clj").write script
  end

  def caveats; <<-EOS.undent
    If you `brew install repl` then you may find this wrapper script from
    MacPorts useful:
      http://trac.macports.org/browser/trunk/dports/lang/clojure/files/clj-rlwrap.sh?format=txt
    EOS
  end

  test do
    system "#{bin}/clj", "-e", '(println "Hello World")'
  end
end
