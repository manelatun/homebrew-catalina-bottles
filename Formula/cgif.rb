# SHA256:2gOPMkIlvwfPbArtAWyv8kj8/ZvCHwRtlvzIRFuyRaQ=

class Cgif < Formula
  desc "GIF encoder written in C"
  homepage "https://github.com/dloebl/cgif"
  url "https://github.com/dloebl/cgif/archive/refs/tags/V0.3.2.tar.gz"
  sha256 "0abf83b7617f4793d9ab3a4d581f4e8d7548b56a29e3f95b0505f842cbfd7f95"
  license "MIT"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 cellar: :any, catalina: "f7979e885f786ad7bc023041653c3a7ad381e57198bc68256dcc5c9f2aa42f71"
  end

  depends_on "manelatun/catalina-bottles/meson" => :build
  depends_on "manelatun/catalina-bottles/ninja" => :build

  def install
    system "meson", "setup", "build", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"try.c").write <<~EOS
      #include <cgif.h>
      int main() {
        CGIF_Config config = {0};
        CGIF *cgif;

        cgif = cgif_newgif(&config);

        return 0;
      }
    EOS
    system ENV.cc, "try.c", "-L#{lib}", "-lcgif", "-o", "try"
    system "./try"
  end
end
