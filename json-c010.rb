class JsonC010 < Formula
  homepage "https://github.com/json-c/json-c/wiki"
  url "https://github.com/downloads/json-c/json-c/json-c-0.10.tar.gz"
  sha256 "274fc9d47c1911fad9caab4db117e4be5d6b68c4547eab0c508d79c4768e170c"

  bottle do
    cellar :any
    sha256 "db1de5a842fe6f047617e8271fcff34aad75c5fc199121ffcff8eba1920d6257" => :yosemite
    sha256 "96227004581799c64d10f4020d371fa8803b93447767c918d9e2f8b2973a267f" => :mavericks
    sha256 "252754be7e562391372918689a6493913b202796010fdf6712dae08d1851c856" => :mountain_lion
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"

    # The Makefile forgets to install this header.
    (include/"json").install "json_object_iterator.h"
  end
end
