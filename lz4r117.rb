class Lz4r117 < Formula
  desc "Lossless compression algorithm"
  homepage "http://www.lz4.info/"
  url "https://github.com/Cyan4973/lz4/archive/r117.tar.gz"
  version "r117"
  sha256 "c4ca70bf6711021d5ae64e79469a619a4e5899a4c7e07e665f3eb3a517cd029d"

  bottle do
    cellar :any
    sha256 "2e34e4bdc4424f019d3626e271a2c206dc59ded5c863711dd979d4ead20bc21c" => :el_capitan
    sha256 "5a470c54018609d55ff28342df3c54f207444e7d3c7a9fa9bfb51210b2a86c0d" => :yosemite
    sha256 "031be16225c00692a6aaa462237d7899ec3435b92b05e20dfdd5781d00a58f08" => :mavericks
  end

  conflicts_with "lz4", :because => "Differing versions of the same formulae"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    input = "testing compression and decompression"
    input_file = testpath/"in"
    input_file.write input
    output_file = testpath/"out"
    system "sh", "-c", "cat #{input_file} | #{bin}/lz4 | #{bin}/lz4 -d > #{output_file}"
    assert_equal output_file.read, input
  end
end
