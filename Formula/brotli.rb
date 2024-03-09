# SHA256:phJXzH+wsuQWvim2wII3m7T3D0UtrnS0iJMarOwc0MI=

class Brotli < Formula
  desc "Generic-purpose lossless compression algorithm by Google"
  homepage "https://github.com/google/brotli"
  url "https://github.com/google/brotli/archive/refs/tags/v1.1.0.tar.gz"
  mirror "http://fresh-center.net/linux/misc/brotli-1.1.0.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/brotli-1.1.0.tar.gz"
  sha256 "e720a6ca29428b803f4ad165371771f5398faba397edf6778837a18599ea13ff"
  license "MIT"
  head "https://github.com/google/brotli.git", branch: "master"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/5ezikk8c/"
    rebuild 2
    sha256 cellar: :any, catalina: "9e7a495e314bd53d9e07a5e7bc3dac9da34e9c6698f6fc41c110dc856d5afe04"
  end

  depends_on "manelatun/catalina-bottles/cmake" => :build

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "VERBOSE=1"
    system "ctest", "-V"
    system "make", "install"
  end

  test do
    (testpath/"file.txt").write("Hello, World!")
    system "#{bin}/brotli", "file.txt", "file.txt.br"
    system "#{bin}/brotli", "file.txt.br", "--output=out.txt", "--decompress"
    assert_equal (testpath/"file.txt").read, (testpath/"out.txt").read
  end
end
