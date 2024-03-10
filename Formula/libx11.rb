# SHA256:JnhSOgEKzLjDbjwLmzgMTfUeq+kAMdrPUCgn/xAlbAo=

class Libx11 < Formula
  desc "X.Org: Core X11 protocol client library"
  homepage "https://www.x.org/"
  url "https://www.x.org/archive/individual/lib/libX11-1.8.7.tar.gz"
  sha256 "793ebebf569f12c864b77401798d38814b51790fce206e01a431e5feb982e20b"
  license "MIT"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 catalina: "08bc2d702142cf46b6f0d9149a2b043407c77223cb10eebc8b3490670b425ed9"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/util-macros" => :build
  depends_on "manelatun/catalina-bottles/xtrans" => :build
  depends_on "manelatun/catalina-bottles/libxcb"
  depends_on "manelatun/catalina-bottles/xorgproto"

  def install
    ENV.delete "LC_ALL"
    ENV["LC_CTYPE"] = "C"
    args = %W[
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-silent-rules
      --enable-unix-transport
      --enable-tcp-transport
      --enable-ipv6
      --enable-loadable-i18n
      --enable-xthreads
      --enable-specs=no
    ]

    system "./configure", *std_configure_args, *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <X11/Xlib.h>
      #include <stdio.h>
      int main() {
        Display* disp = XOpenDisplay(NULL);
        if (disp == NULL)
        {
          fprintf(stderr, "Unable to connect to display\\n");
          return 0;
        }

        int screen_num = DefaultScreen(disp);
        unsigned long background = BlackPixel(disp, screen_num);
        unsigned long border = WhitePixel(disp, screen_num);
        int width = 60, height = 40;
        Window win = XCreateSimpleWindow(disp, DefaultRootWindow(disp), 0, 0, width, height, 2, border, background);
        XSelectInput(disp, win, ButtonPressMask|StructureNotifyMask);
        XMapWindow(disp, win); // display blank window

        XGCValues values;
        values.foreground = WhitePixel(disp, screen_num);
        values.line_width = 1;
        values.line_style = LineSolid;
        GC pen = XCreateGC(disp, win, GCForeground|GCLineWidth|GCLineStyle, &values);
        // draw two diagonal lines
        XDrawLine(disp, win, pen, 0, 0, width, height);
        XDrawLine(disp, win, pen, width, 0, 0, height);

        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lX11", "-o", "test", "-I#{include}"
    system "./test"
  end
end
