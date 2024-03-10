# SHA256:6JRkSVn5junTXMwvBRofO4mKLFApiJbObfGZicD4bkU=

class Libxrender < Formula
  desc "X.Org: Library for the Render Extension to the X11 protocol"
  homepage "https://www.x.org/"
  url "https://www.x.org/archive/individual/lib/libXrender-0.9.11.tar.gz"
  sha256 "6aec3ca02e4273a8cbabf811ff22106f641438eb194a12c0ae93c7e08474b667"
  license "MIT"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 cellar: :any, catalina: "2a3ab06fbab0d73f45c28541c888a82df5fa9d3fa711144007484310bd794d4f"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/libx11"
  depends_on "manelatun/catalina-bottles/xorgproto"

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-dependency-tracking
      --disable-silent-rules
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "X11/Xlib.h"
      #include "X11/extensions/Xrender.h"

      int main(int argc, char* argv[]) {
        XRenderColor color;
        return 0;
      }
    EOS
    system ENV.cc, "test.c"
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
