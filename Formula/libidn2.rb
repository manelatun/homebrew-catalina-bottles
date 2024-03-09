# SHA256:IdekjPuCjQ2I1TjQ8DUNgdFPcjQBxrb7/H4DBu44DcY=

class Libidn2 < Formula
  desc "International domain name library (IDNA2008, Punycode and TR46)"
  homepage "https://www.gnu.org/software/libidn/#libidn2"
  url "https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz"
  mirror "https://ftpmirror.gnu.org/libidn/libidn2-2.3.7.tar.gz"
  mirror "http://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz"
  sha256 "4c21a791b610b9519b9d0e12b8097bf2f359b12f8dd92647611a929e6bfd7d64"
  license any_of: ["GPL-2.0-or-later", "LGPL-3.0-or-later"]

  livecheck do
    url :stable
    regex(/href=.*?libidn2[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 catalina: "55f4a32ca5a1759c1bac75a8048544a76bca6a6902ce94eb93c797dde46279f0"
  end

  head do
    url "https://gitlab.com/libidn/libidn2.git", branch: "master"

    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/gengetopt" => :build
    depends_on "manelatun/catalina-bottles/gettext" => :build
    depends_on "manelatun/catalina-bottles/help2man" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
    depends_on "manelatun/catalina-bottles/ronn" => :build

    uses_from_macos "gperf" => :build

    on_system :linux, macos: :ventura_or_newer do
      depends_on "manelatun/catalina-bottles/texinfo" => :build
    end
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/libunistring"

  on_macos do
    depends_on "manelatun/catalina-bottles/gettext"
  end

  def install
    args = ["--disable-silent-rules", "--with-packager=Homebrew"]
    args << "--with-libintl-prefix=#{Formula["gettext"].opt_prefix}" if OS.mac?

    system "./bootstrap", "--skip-po" if build.head?
    system "./configure", *std_configure_args, *args
    system "make", "install"
  end

  test do
    ENV.delete("LC_CTYPE")
    ENV["CHARSET"] = "UTF-8"
    output = shell_output("#{bin}/idn2 räksmörgås.se")
    assert_equal "xn--rksmrgs-5wao1o.se", output.chomp
    output = shell_output("#{bin}/idn2 blåbærgrød.no")
    assert_equal "xn--blbrgrd-fxak7p.no", output.chomp
  end
end
