# SHA256:x8neNm0A3Y1jNCzp+t+KOoTu58kb7tKrMr3O5D9iq6g=

class Libmpc < Formula
  desc "C library for the arithmetic of high precision complex numbers"
  homepage "https://www.multiprecision.org/"
  url "https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
  mirror "https://ftpmirror.gnu.org/mpc/mpc-1.3.1.tar.gz"
  sha256 "ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8"
  license "LGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 cellar: :any, catalina: "8bf476a14a2da64a21a5722c5dd52cd0f594c3cee41df9a5c3be3ee780157b31"
  end

  head do
    url "https://gitlab.inria.fr/mpc/mpc.git", branch: "master"
    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
  end

  depends_on "manelatun/catalina-bottles/gmp"
  depends_on "manelatun/catalina-bottles/mpfr"

  def install
    system "autoreconf", "--force", "--install", "--verbose" if build.head?
    system "./configure", *std_configure_args,
                          "--with-gmp=#{Formula["gmp"].opt_prefix}",
                          "--with-mpfr=#{Formula["mpfr"].opt_prefix}"
    system "make"
    system "make", "check"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <mpc.h>
      #include <assert.h>
      #include <math.h>

      int main() {
        mpc_t x;
        mpc_init2 (x, 256);
        mpc_set_d_d (x, 1., INFINITY, MPC_RNDNN);
        mpc_tanh (x, x, MPC_RNDNN);
        assert (mpfr_nan_p (mpc_realref (x)) && mpfr_nan_p (mpc_imagref (x)));
        mpc_clear (x);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-L#{Formula["mpfr"].opt_lib}",
                   "-L#{Formula["gmp"].opt_lib}", "-lmpc", "-lmpfr",
                   "-lgmp", "-o", "test"
    system "./test"
  end
end
