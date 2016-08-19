class ClangFormat38 < Formula
  desc "Formatting tools for C, C++, ObjC, Java, JavaScript, TypeScript"
  homepage "http://clang.llvm.org/docs/ClangFormat.html"
  url "http://llvm.org/releases/3.8.0/llvm-3.8.0.src.tar.xz"
  sha256 "555b028e9ee0f6445ff8f949ea10e9cd8be0d084840e21fbbe1d31d51fc06e46"

  bottle do
    cellar :any_skip_relocation
    sha256 "4d68bd49d9d837144da9921ee28a61419ec306035c2a127af1df8961a1e9d1db" => :el_capitan
    sha256 "ce8d399f32942a3414c9f1d142a647f14fabc8d043c603ebba8bba20478bce2d" => :yosemite
    sha256 "69e3bc7fec832ea0976179f2723905efbe351ba4f36c9e15f144ba61b4f008e4" => :mavericks
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "subversion" => :build

  conflicts_with "clang-format", :because => "Differing versions of the same formula"

  resource "clang" do
    url "http://llvm.org/releases/3.8.0/cfe-3.8.0.src.tar.xz"
    sha256 "04149236de03cf05232d68eb7cb9c50f03062e339b68f4f8a03b650a11536cf9"
  end

  resource "libcxx" do
    url "http://llvm.org/releases/3.8.0/libcxx-3.8.0.src.tar.xz"
    sha256 "36804511b940bc8a7cefc7cb391a6b28f5e3f53f6372965642020db91174237b"
  end

  def install
    (buildpath/"projects/libcxx").install resource("libcxx")
    (buildpath/"tools/clang").install resource("clang")

    mkdir "build" do
      args = std_cmake_args
      args << "-DLLVM_ENABLE_LIBCXX=ON"
      args << ".."
      system "cmake", "-G", "Ninja", *args
      system "ninja", "clang-format"
      bin.install "bin/clang-format"
    end
    bin.install "tools/clang/tools/clang-format/git-clang-format"
    (share/"clang").install Dir["tools/clang/tools/clang-format/clang-format*"]
  end

  test do
    # NB: below C code is messily formatted on purpose.
    (testpath/"test.c").write <<-EOS
      int         main(char *args) { \n   \t printf("hello"); }
    EOS

    assert_equal "int main(char *args) { printf(\"hello\"); }\n",
        shell_output("#{bin}/clang-format -style=Google test.c")
  end
end
