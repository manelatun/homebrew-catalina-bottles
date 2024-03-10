# SHA256:rZsJ9paDC2poREyL66U5XBxFq2b/VE4+h1RIN6PvIS4=

class Pixman < Formula
  desc "Low-level library for pixel manipulation"
  homepage "https://cairographics.org/"
  url "https://cairographics.org/releases/pixman-0.42.2.tar.gz"
  sha256 "ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e"
  license "MIT"

  livecheck do
    url "https://cairographics.org/releases/?C=M&O=D"
    regex(/href=.*?pixman[._-]v?(\d+\.\d*[02468](?:\.\d+)*)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 2
    sha256 cellar: :any, catalina: "212d32741ea66fb9e43075cca927e82401ee3d0e06addcc03c50e78bab1dffed"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build

  # Fix NEON intrinsic support build issue
  # upstream PR ref, https://gitlab.freedesktop.org/pixman/pixman/-/merge_requests/71
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/46c7779/pixman/pixman-0.42.2.patch"
    sha256 "391b56552ead4b3c6e75c0a482a6ab6a634ca250c00fb67b11899d16575f0686"
  end

  def install
    args = ["--disable-gtk", "--disable-silent-rules"]

    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <pixman.h>

      int main(int argc, char *argv[])
      {
        pixman_color_t white = { 0xffff, 0xffff, 0xffff, 0xffff };
        pixman_image_t *image = pixman_image_create_solid_fill(&white);
        pixman_image_unref(image);
        return 0;
      }
    EOS
    flags = %W[
      -I#{include}/pixman-1
      -L#{lib}
      -lpixman-1
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
