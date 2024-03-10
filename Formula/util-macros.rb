# SHA256:5TNvnVrjyfKET2IKGJ0OPIcaIbdwoRjmhxU1QLgCVKo=

class UtilMacros < Formula
  desc "X.Org: Set of autoconf macros used to build other xorg packages"
  homepage "https://www.x.org/"
  url "https://www.x.org/archive/individual/util/util-macros-1.20.0.tar.xz"
  sha256 "0b86b262dbe971edb4ff233bc370dfad9f241d09f078a3f6d5b7f4b8ea4430db"
  license "MIT"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "e89c9d80b7c6fb1f5c22ee4ccc0d6418e0e4d90deb954f493562fa4d0769adbe"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :test

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
    ]

    system "./configure", *args
    system "make", "install"
  end

  test do
    system "pkg-config", "--exists", "xorg-macros"
    assert_equal 0, $CHILD_STATUS.exitstatus
  end
end
