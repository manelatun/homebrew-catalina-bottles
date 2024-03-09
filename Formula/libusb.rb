# SHA256:LOZM/jdJ1Ovc6Df1OKD7nS77To5S30h3Rwvu5rOJKcs=

class Libusb < Formula
  desc "Library for USB device access"
  homepage "https://libusb.info/"
  url "https://github.com/libusb/libusb/releases/download/v1.0.27/libusb-1.0.27.tar.bz2"
  sha256 "ffaa41d741a8a3bee244ac8e54a72ea05bf2879663c098c82fc5757853441575"
  license "LGPL-2.1-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 cellar: :any, catalina: "7acc8e2cf38da9e43af76269571c5d557b17e1dace175cb4ab72814059af40a4"
  end

  head do
    url "https://github.com/libusb/libusb.git", branch: "master"

    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
  end

  on_linux do
    depends_on "manelatun/catalina-bottles/systemd"
  end

  def install
    args = %W[--disable-dependency-tracking --prefix=#{prefix}]

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
    (pkgshare/"examples").install Dir["examples/*"] - Dir["examples/Makefile*"]
  end

  test do
    cp_r (pkgshare/"examples"), testpath
    cd "examples" do
      system ENV.cc, "listdevs.c", "-L#{lib}", "-I#{include}/libusb-1.0",
             "-lusb-1.0", "-o", "test"
      system "./test"
    end
  end
end
