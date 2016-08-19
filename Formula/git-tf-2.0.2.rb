class GitTf202 < Formula
  homepage "https://gittf.codeplex.com/"
  url "http://download.microsoft.com/download/A/E/2/AE23B059-5727-445B-91CC-15B7A078A7F4/git-tf-2.0.2.20130214.zip"
  sha256 "2fb6d0c494b8f7007b3222f20d1fd3f5c7f406c35801f22d717c71115057eb15"

  bottle :unneeded

  conflicts_with "git-tf", :because => "two different versions of the same library"

  def install
    libexec.install "git-tf"
    libexec.install "lib"
    (libexec+"native").install "native/macosx"
    bin.write_exec_script libexec/"git-tf"
    (share/"doc/git-tf").install Dir["Git-TF_*"] + Dir["ThirdPartyNotices*"]
  end

  test do
    system bin/"git-tf"
  end
end
