# SHA256:pTCCmh6ppjgw3paza2Cb2J86QQwN7bU3iwcS12ZUy24=

class Gnutls < Formula
  desc "GNU Transport Layer Security (TLS) Library"
  homepage "https://gnutls.org/"
  url "https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.3.tar.xz"
  mirror "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v3.8/gnutls-3.8.3.tar.xz"
  sha256 "f74fc5954b27d4ec6dfbb11dea987888b5b124289a3703afcada0ee520f4173e"
  license all_of: ["LGPL-2.1-or-later", "GPL-3.0-only"]

  livecheck do
    url "https://www.gnutls.org/news.html"
    regex(/>\s*GnuTLS\s*v?(\d+(?:\.\d+)+)\s*</i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 catalina: "2687b2c1061b7da5e6453d09d8b0df110ffc7f3d1d05f87a23d98c9aa303bbba"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/ca-certificates"
  depends_on "manelatun/catalina-bottles/gmp"
  depends_on "manelatun/catalina-bottles/libidn2"
  depends_on "manelatun/catalina-bottles/libtasn1"
  depends_on "manelatun/catalina-bottles/libunistring"
  depends_on "manelatun/catalina-bottles/nettle"
  depends_on "manelatun/catalina-bottles/p11-kit"
  depends_on "manelatun/catalina-bottles/unbound"

  uses_from_macos "zlib"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --disable-static
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-default-trust-store-file=#{pkgetc}/cert.pem
      --disable-heartbeat-support
      --with-p11-kit
    ]

    system "./configure", *args
    system "make", "install"

    # certtool shadows the macOS certtool utility
    mv bin/"certtool", bin/"gnutls-certtool"
    mv man1/"certtool.1", man1/"gnutls-certtool.1"
  end

  def post_install
    rm_f pkgetc/"cert.pem"
    pkgetc.install_symlink Formula["ca-certificates"].pkgetc/"cert.pem"
  end

  def caveats
    <<~EOS
      Guile bindings are now in the `guile-gnutls` formula.
    EOS
  end

  test do
    system bin/"gnutls-cli", "--version"
    assert_match "expired certificate", shell_output("#{bin}/gnutls-cli expired.badssl.com", 1)
  end
end
