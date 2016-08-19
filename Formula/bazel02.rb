class Bazel02 < Formula
  desc "Google's own build tool"
  homepage "http://bazel.io/"
  url "https://github.com/bazelbuild/bazel/archive/0.2.3.tar.gz"
  sha256 "37fd2d49c57df171b704bf82c94e7bf954d94748e2a8621c5456c5c9d5f2c845"
  head "https://github.com/bazelbuild/bazel.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "1152d7c0c2041bc0a346ad85426b4ee3add0ce39ffa37ba83b390648b28dc4cf" => :el_capitan
    sha256 "d1b33ce6f3186c65528ef941fca40cfd7a25b7a4307370975000c51493dce6ce" => :yosemite
  end

  depends_on :java => "1.8+"
  depends_on :macos => :yosemite

  conflicts_with "bazel", :because => "Differing version of same formula"

  def install
    ENV["EMBED_LABEL"] = "#{version}-homebrew"

    system "./compile.sh"
    system "./output/bazel", "build", "scripts:bash_completion"

    bin.install "output/bazel" => "bazel"
    bash_completion.install "bazel-bin/scripts/bazel-complete.bash"
    zsh_completion.install "scripts/zsh_completion/_bazel"
  end

  test do
    touch testpath/"WORKSPACE"

    (testpath/"ProjectRunner.java").write <<-EOS.undent
      public class ProjectRunner {
        public static void main(String args[]) {
          System.out.println("Hi!");
        }
      }
    EOS

    (testpath/"BUILD").write <<-EOS.undent
      java_binary(
        name = "bazel-test",
        srcs = glob(["*.java"]),
        main_class = "ProjectRunner",
      )
    EOS

    system "#{bin}/bazel", "build", "//:bazel-test"
    system "bazel-bin/bazel-test"
  end
end
