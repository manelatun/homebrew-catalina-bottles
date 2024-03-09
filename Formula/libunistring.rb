# SHA256:xJM3Ui9EgYLTtSCW6uwCzJN0GjvgIKeSB0FJUSK6Ssg=

class Libunistring < Formula
  desc "C string library for manipulating Unicode strings"
  homepage "https://www.gnu.org/software/libunistring/"
  url "https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.gz"
  mirror "https://ftpmirror.gnu.org/libunistring/libunistring-1.2.tar.gz"
  mirror "http://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.gz"
  sha256 "fd6d5662fa706487c48349a758b57bc149ce94ec6c30624ec9fdc473ceabbc8e"
  license any_of: ["GPL-2.0-only", "LGPL-3.0-or-later"]

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 cellar: :any, catalina: "01dea4ebfb119f7f39550c1c7b6a62dfb78b7d59fdb865dc7bf97f6d798f396c"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "check" if !OS.mac? || MacOS.version != :sonoma
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <uniname.h>
      #include <unistdio.h>
      #include <unistr.h>
      #include <stdlib.h>
      int main (void) {
        uint32_t s[2] = {};
        uint8_t buff[12] = {};
        if (u32_uctomb (s, unicode_name_character ("BEER MUG"), sizeof s) != 1) abort();
        if (u8_sprintf (buff, "%llU", s) != 4) abort();
        printf ("%s\\n", buff);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lunistring",
                   "-o", "test"
    assert_equal "🍺", shell_output("./test").chomp
  end
end
