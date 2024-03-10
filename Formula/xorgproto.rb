# SHA256:Uj4qWoItLNtusqwdEiYZ3U2pDLemjaPHHNzSpPiTtWo=

class Xorgproto < Formula
  desc "X.Org: Protocol Headers"
  homepage "https://www.x.org/"
  url "https://xorg.freedesktop.org/archive/individual/proto/xorgproto-2023.2.tar.gz"
  sha256 "c791aad9b5847781175388ebe2de85cb5f024f8dabf526d5d699c4f942660cc3"
  license "MIT"

  livecheck do
    url :stable
    regex(/href=.*?xorgproto[._-]v?(\d+\.\d+(?:\.([0-8]\d*?)?\d(?:\.\d+)*)?)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "13fd7b776b844251bbe8ba9bff128c9dfd362cbce5d82f20648beb172534994f"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => [:build, :test]
  depends_on "manelatun/catalina-bottles/util-macros" => :build

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-dependency-tracking
      --disable-silent-rules
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    assert_equal "-I#{include}", shell_output("pkg-config --cflags xproto").chomp
    assert_equal "-I#{include}/X11/dri", shell_output("pkg-config --cflags xf86driproto").chomp
  end
end
