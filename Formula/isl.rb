# SHA256:BLe1qA4mpkwG+Q6lE0anOuUX3saCrcF/noLheWWIF4c=

class Isl < Formula
  # NOTE: Always use tarball instead of git tag for stable version.
  #
  # Currently isl detects its version using source code directory name
  # and update isl_version() function accordingly.  All other names will
  # result in isl_version() function returning "UNKNOWN" and hence break
  # package detection.
  desc "Integer Set Library for the polyhedral model"
  homepage "https://libisl.sourceforge.io/"
  url "https://libisl.sourceforge.io/isl-0.26.tar.xz"
  sha256 "a0b5cb06d24f9fa9e77b55fabbe9a3c94a336190345c2555f9915bb38e976504"
  license "MIT"

  livecheck do
    url :homepage
    regex(/href=.*?isl[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 cellar: :any, catalina: "34799078d227e931b15fa5c7adc6450f89e74e21837657eea49ef1d3f746711c"
  end

  head do
    url "https://repo.or.cz/isl.git"

    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
  end

  depends_on "manelatun/catalina-bottles/gmp"

  def install
    system "./autogen.sh" if build.head?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp"].opt_prefix}"
    system "make"
    system "make", "install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <isl/ctx.h>

      int main()
      {
        isl_ctx* ctx = isl_ctx_alloc();
        isl_ctx_free(ctx);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lisl", "-o", "test"
    system "./test"
  end
end
