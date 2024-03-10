# SHA256:0pMrEXnYKp+CaS6a3HNOAD1TDroSXrysPimTF79BNDQ=

class Fontconfig < Formula
  desc "XML-based font configuration API for X Windows"
  homepage "https://wiki.freedesktop.org/www/Software/fontconfig/"
  url "https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.15.0.tar.xz"
  sha256 "63a0658d0e06e0fa886106452b58ef04f21f58202ea02a94c39de0d3335d7c0e"
  license "MIT"

  livecheck do
    url :stable
    regex(/href=.*?fontconfig[._-]v?(\d+\.\d+\.(?:\d|[0-8]\d+))\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 catalina: "c3cb7790ea2ff2d0a4eb4cc3654e1852b97752f8206fb9f4f61322cccde76a28"
  end

  head do
    url "https://gitlab.freedesktop.org/fontconfig/fontconfig.git"

    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/gettext" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/freetype"

  uses_from_macos "gperf" => :build
  uses_from_macos "python" => :build, since: :catalina
  uses_from_macos "bzip2"
  uses_from_macos "expat"

  on_linux do
    depends_on "manelatun/catalina-bottles/gettext" => :build
    depends_on "manelatun/catalina-bottles/json-c" => :build
    depends_on "manelatun/catalina-bottles/util-linux"
  end

  def install
    font_dirs = %w[
      /System/Library/Fonts
      /Library/Fonts
      ~/Library/Fonts
    ]

    if OS.mac? && MacOS.version >= :sierra
      font_dirs << Dir["/System/Library/Assets{,V2}/com_apple_MobileAsset_Font*"].max
    end

    system "autoreconf", "-iv" if build.head?
    ENV["UUID_CFLAGS"] = "-I#{Formula["util-linux"].include}" if OS.linux?
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--disable-docs",
                          "--enable-static",
                          "--with-add-fonts=#{font_dirs.join(",")}",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}",
                          "--sysconfdir=#{etc}"
    system "make", "install", "RUN_FC_CACHE_TEST=false"
  end

  def post_install
    ohai "Regenerating font cache, this may take a while"
    system "#{bin}/fc-cache", "-frv"
  end

  test do
    system "#{bin}/fc-list"
  end
end
