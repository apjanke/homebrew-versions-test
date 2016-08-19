class Riak132 < Formula
  desc "Distributed database"
  homepage "http://basho.com/riak/"
  url "http://s3.amazonaws.com/downloads.basho.com/riak/1.3/1.3.2/osx/10.8/riak-1.3.2-osx-x86_64.tar.gz"
  version "1.3.2"
  sha256 "3a31e7dd00487b4758307d9932a508401ed1763ed3360cbe8ca9615e2ffd7c0e"

  conflicts_with "riak"

  depends_on :macos => :mountain_lion
  depends_on :arch => :x86_64
  depends_on "erlang"

  def install
    libexec.install Dir["*"]
    bin.write_exec_script libexec/"bin/riak"
    bin.write_exec_script libexec/"bin/riak-admin"
    bin.write_exec_script libexec/"bin/riak-debug"
    bin.write_exec_script libexec/"bin/search-cmd"
  end
end
