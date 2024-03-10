# SHA256:FXs6X9byuQL6Ga8MMSma2UV3BbDvujbDhyIVcHJg5pM=

class XcbProto < Formula
  desc "X.Org: XML-XCB protocol descriptions for libxcb code generation"
  homepage "https://www.x.org/"
  url "https://xorg.freedesktop.org/archive/individual/proto/xcb-proto-1.16.0.tar.xz"
  sha256 "a75a1848ad2a89a82d841a51be56ce988ff3c63a8d6bf4383ae3219d8d915119"
  license "MIT"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 2
    sha256 cellar: :any_skip_relocation, catalina: "02448041cec1382d4cee7e2c0b995f9e6065ef7bd192b362f74dcf94d4af30b9"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => [:build, :test]
  depends_on "manelatun/catalina-bottles/python@3.12" => [:build, :test]

  def python3
    "python3.12"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --localstatedir=#{var}
      --disable-silent-rules
      PYTHON=#{python3}
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    assert_match "#{share}/xcb", shell_output("pkg-config --variable=xcbincludedir xcb-proto").chomp
    system python3, "-c", <<~EOS
      import collections
      output = collections.defaultdict(int)
      from xcbgen import xtypes
    EOS
  end
end
