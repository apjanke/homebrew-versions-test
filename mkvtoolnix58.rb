class Mkvtoolnix58 < Formula
  desc "Matroska media files manipulation tools"
  homepage "https://www.bunkus.org/videotools/mkvtoolnix/"
  url "https://www.bunkus.org/videotools/mkvtoolnix/sources/mkvtoolnix-5.8.0.tar.bz2"
  sha256 "3c9ec7e4c035b82a35850c5ada98a29904edc44a0d1c9b900ed05d56e6274960"

  bottle do
    sha256 "16bcf30898539320690492bdd7d48561d9633a7b127c0c1689788110eff53651" => :yosemite
    sha256 "c58a9c895e5a915c7c8de33a61392e25d40717a103032adbf53c559d75d6d7df" => :mavericks
  end

  depends_on :ruby => "1.9"
  depends_on "pkg-config" => :build
  depends_on "libvorbis"
  depends_on "flac" => :optional
  depends_on "lzo" => :optional

  # On Mavericks, the bottle (without c++11) can be used
  # because mkvtoolnix is linked against libc++ by default
  if MacOS.version >= "10.9"
    depends_on "boost155"
    depends_on "libmatroska"
    depends_on "libebml"
  else
    depends_on "boost155" => "c++11"
    depends_on "libmatroska" => "c++11"
    depends_on "libebml" => "c++11"
  end

  needs :cxx11

  def install
    ENV.cxx11

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-gui",
                          "--disable-wxwidgets",
                          "--without-curl",
                          "--with-boost=#{Formula["boost155"].opt_prefix}"

    system "./drake", "-j#{ENV.make_jobs}"
    system "./drake", "install"
  end

  test do
    mkv_path = testpath/"Great.Movie.mkv"
    sub_path = testpath/"subtitles.srt"
    sub_path.write <<-EOS.undent
      1
      00:00:10,500 --> 00:00:13,000
      Homebrew
    EOS

    system "#{bin}/mkvmerge", "-o", mkv_path, sub_path
    system "#{bin}/mkvinfo", mkv_path
    system "#{bin}/mkvextract", "tracks", mkv_path, "0:#{sub_path}"
  end
end
