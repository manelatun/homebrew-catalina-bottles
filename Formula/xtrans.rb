# SHA256:nlekbTeMmuBYWetEtficAGuXEjcPnc++7g8vNEeH5og=

class Xtrans < Formula
  desc "X.Org: X Network Transport layer shared code"
  homepage "https://www.x.org/"
  url "https://www.x.org/archive/individual/lib/xtrans-1.5.0.tar.xz"
  sha256 "1ba4b703696bfddbf40bacf25bce4e3efb2a0088878f017a50e9884b0c8fb1bd"
  license "MIT"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 3
    sha256 cellar: :any_skip_relocation, catalina: "bc27bd136f4f9f329cd6a49a7238c1dd0326e5e393d5a27e49cf1e835063b59e"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/util-macros" => :build
  depends_on "manelatun/catalina-bottles/xorgproto" => :test

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-docs=no
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "X11/Xtrans/Xtrans.h"

      int main(int argc, char* argv[]) {
        Xtransaddr addr;
        return 0;
      }
    EOS
    system ENV.cc, "test.c"
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
