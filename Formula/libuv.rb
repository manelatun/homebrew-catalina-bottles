# SHA256:Qz5pohK0Mpl07qVY+hP9+gqM7VX5gdyuxq61yI5h6pI=

class Libuv < Formula
  desc "Multi-platform support library with a focus on asynchronous I/O"
  homepage "https://libuv.org"
  url "https://github.com/libuv/libuv/archive/refs/tags/v1.48.0.tar.gz"
  sha256 "8c253adb0f800926a6cbd1c6576abae0bc8eb86a4f891049b72f9e5b7dc58f33"
  license "MIT"
  head "https://github.com/libuv/libuv.git", branch: "v1.x"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/wluewbcs/"
    rebuild 1
    sha256 cellar: :any, catalina: "7a5535ad68f810d5dc740694a76af03862203c1618f33534cc5f0284b928a511"
  end

  depends_on "manelatun/catalina-bottles/autoconf" => :build
  depends_on "manelatun/catalina-bottles/automake" => :build
  depends_on "manelatun/catalina-bottles/libtool" => :build
  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/sphinx-doc" => :build

  def install
    # This isn't yet handled by the make install process sadly.
    cd "docs" do
      system "make", "man"
      man1.install "build/man/libuv.1"
    end

    system "./autogen.sh"
    system "./configure", *std_configure_args,
                          "--disable-silent-rules"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <uv.h>
      #include <stdlib.h>

      int main()
      {
        uv_loop_t* loop = malloc(sizeof *loop);
        uv_loop_init(loop);
        uv_loop_close(loop);
        free(loop);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-luv", "-o", "test"
    system "./test"
  end
end
