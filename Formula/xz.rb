# SHA256:WMD/WtYdakyA2aW7OaOQDE2F6ogFNfOdxpiNK/aMcL4=

class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "https://xz.tukaani.org/xz-utils/"
  # The archive.org mirror below needs to be manually created at `archive.org`.
  url "https://github.com/tukaani-project/xz/releases/download/v5.6.0/xz-5.6.0.tar.gz"
  mirror "https://downloads.sourceforge.net/project/lzmautils/xz-5.6.0.tar.gz"
  mirror "https://archive.org/download/xz-5.6.0/xz-5.6.0.tar.gz"
  mirror "http://archive.org/download/xz-5.6.0/xz-5.6.0.tar.gz"
  sha256 "0f5c81f14171b74fcc9777d302304d964e63ffc2d7b634ef023a7249d9b5d875"
  license all_of: [
    "0BSD",
    "LGPL-2.1-or-later",
    "GPL-2.0-or-later",
    "GPL-3.0-or-later",
  ]

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 2
    sha256 cellar: :any, catalina: "8a4a3c66ac26f9c9ba2b8d6f1e7c0a6718fc0e5da7842b4be1a15c8b8d8a8dd4"
  end

  def install
    system "./configure", *std_configure_args, "--disable-silent-rules", "--disable-nls"
    system "make", "check"
    system "make", "install"
  end

  test do
    path = testpath/"data.txt"
    original_contents = "." * 1000
    path.write original_contents

    # compress: data.txt -> data.txt.xz
    system bin/"xz", path
    refute_predicate path, :exist?

    # decompress: data.txt.xz -> data.txt
    system bin/"xz", "-d", "#{path}.xz"
    assert_equal original_contents, path.read

    # Check that http mirror works
    xz_tar = testpath/"xz.tar.gz"
    stable.mirrors.each do |mirror|
      next if mirror.start_with?("https")

      xz_tar.unlink if xz_tar.exist?
      system "curl", "--location", mirror, "--output", xz_tar
      assert_equal stable.checksum.hexdigest, xz_tar.sha256
    end
  end
end
