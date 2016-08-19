class Nifi021 < Formula
  desc "Easy, reliable system to process and distribute data"
  homepage "https://nifi.apache.org"
  url "https://archive.apache.org/dist/nifi/0.2.1/nifi-0.2.1-bin.tar.gz"
  sha256 "e151dab553a8ea466f7462d75145e2aa08ced938499aef184850aa4d3209c605"

  conflicts_with "nifi", :because => "Differing versions of the same formula"

  bottle :unneeded

  depends_on :java => "1.7+"

  def install
    libexec.install Dir["*"]

    ENV["NIFI_HOME"] = libexec

    bin.install libexec/"bin/nifi.sh" => "nifi"
    bin.env_script_all_files libexec/"bin/", :NIFI_HOME => libexec
  end

  test do
    system bin/"nifi", "status"
  end
end
