# SHA256:VtzdBls6Kjh//qyhtv/r0iiX5p2eYpjHpL7aJCOUjwo=

class Freetype < Formula
  desc "Software library to render fonts"
  homepage "https://www.freetype.org/"
  url "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz"
  mirror "https://download.savannah.gnu.org/releases/freetype/freetype-2.13.2.tar.xz"
  sha256 "12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d"
  license "FTL"

  livecheck do
    url :stable
    regex(/url=.*?freetype[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 2
    sha256 cellar: :any, catalina: "24c06b84c6512d5a6d38ffad666f21a247b60c34ff30b63bb670d7322507d0c4"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/libpng"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    # This file will be installed to bindir, so we want to avoid embedding the
    # absolute path to the pkg-config shim.
    inreplace "builds/unix/freetype-config.in", "%PKG_CONFIG%", "pkg-config"

    system "./configure", "--prefix=#{prefix}",
                          "--enable-freetype-config",
                          "--without-harfbuzz"
    system "make"
    system "make", "install"

    inreplace [bin/"freetype-config", lib/"pkgconfig/freetype2.pc"],
      prefix, opt_prefix
  end

  test do
    system bin/"freetype-config", "--cflags", "--libs", "--ftversion",
                                  "--exec-prefix", "--prefix"
  end
end
