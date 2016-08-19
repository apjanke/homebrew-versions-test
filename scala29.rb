class Scala29 < Formula
  desc "Programming language"
  homepage "http://www.scala-lang.org/"
  url "http://www.scala-lang.org/files/archive/scala-2.9.3.tgz"
  sha256 "faaab229f78c945063e8fd31c045bc797c731194296d7a4f49863fd87fc4e7b9"

  keg_only "Conflicts with scala in main repository."

  option "with-docs", "Also install library documentation"

  resource "docs" do
    url "http://www.scala-lang.org/files/archive/scala-docs-2.9.3.zip"
    sha256 "98f201dd6a83d9093969825e67d6f248a30f6ccbd83a99a8760245521a16de92"
  end

  resource "completion" do
    url "https://raw.github.com/scala/scala-dist/27bc0c25145a83691e3678c7dda602e765e13413/completion.d/2.9.1/scala"
    sha256 "95aeba51165ce2c0e36e9bf006f2904a90031470ab8d10b456e7611413d7d3fd"
  end

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir["doc/*"]
    man1.install Dir["man/man1/*"]
    libexec.install Dir["*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
    bash_completion.install resource("completion")
    doc.install resource("docs") if build.with? "docs"
  end
end
