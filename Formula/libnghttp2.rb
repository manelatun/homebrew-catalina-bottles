# SHA256:pX7FzvGehvYi3VdbEhT48UCb4WkeCNrC/iMYIKM5m/Y=

class Libnghttp2 < Formula
  desc "HTTP/2 C Library"
  homepage "https://nghttp2.org/"
  url "https://github.com/nghttp2/nghttp2/releases/download/v1.60.0/nghttp2-1.60.0.tar.gz"
  mirror "http://fresh-center.net/linux/www/nghttp2-1.60.0.tar.gz"
  mirror "http://fresh-center.net/linux/www/legacy/nghttp2-1.60.0.tar.gz"
  # this legacy mirror is for user to install from the source when https not working for them
  # see discussions in here, https://github.com/Homebrew/homebrew-core/pull/133078#discussion_r1221941917
  sha256 "ca2333c13d1af451af68de3bd13462de7e9a0868f0273dea3da5bc53ad70b379"
  license "MIT"

  livecheck do
    formula "nghttp2"
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 cellar: :any, catalina: "dcec2f616261fca58f164ffe4f65788dad08f00b39037c012ce0b93d24f4bfc3"
  end

  head do
    url "https://github.com/nghttp2/nghttp2.git", branch: "master"

    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build

  # These used to live in `nghttp2`.
  link_overwrite "include/nghttp2"
  link_overwrite "lib/libnghttp2.a"
  link_overwrite "lib/libnghttp2.dylib"
  link_overwrite "lib/libnghttp2.14.dylib"
  link_overwrite "lib/libnghttp2.so"
  link_overwrite "lib/libnghttp2.so.14"
  link_overwrite "lib/pkgconfig/libnghttp2.pc"

  def install
    system "autoreconf", "-ivf" if build.head?
    system "./configure", *std_configure_args, "--enable-lib-only"
    system "make", "-C", "lib"
    system "make", "-C", "lib", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <nghttp2/nghttp2.h>
      #include <stdio.h>

      int main() {
        nghttp2_info *info = nghttp2_version(0);
        printf("%s", info->version_str);
        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lnghttp2", "-o", "test"
    assert_equal version.to_s, shell_output("./test")
  end
end
