# SHA256:7IYR4SDB1/VcHcEyGXdNb2C0LssG+/3DuSX+JqX2dXo=

class Automake < Formula
  desc "Tool for generating GNU Standards-compliant Makefiles"
  homepage "https://www.gnu.org/software/automake/"
  url "https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz"
  mirror "https://ftpmirror.gnu.org/automake/automake-1.16.5.tar.xz"
  sha256 "f01d58cd6d9d77fbdca9eb4bbd5ead1988228fdb73d6f7a201f5f8d6b118b469"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "9935494521e18f2e5a45b649aeb4968922586ae5997122f3f902dc2ae4007477"
  end

  depends_on "manelatun/catalina-bottles/autoconf"

  def install
    ENV["PERL"] = "/usr/bin/perl" if OS.mac?

    system "./configure", "--prefix=#{prefix}"
    system "make", "install"

    # Our aclocal must go first. See:
    # https://github.com/Homebrew/homebrew/issues/10618
    (share/"aclocal/dirlist").write <<~EOS
      #{HOMEBREW_PREFIX}/share/aclocal
      /usr/share/aclocal
    EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      int main() { return 0; }
    EOS
    (testpath/"configure.ac").write <<~EOS
      AC_INIT(test, 1.0)
      AM_INIT_AUTOMAKE
      AC_PROG_CC
      AC_CONFIG_FILES(Makefile)
      AC_OUTPUT
    EOS
    (testpath/"Makefile.am").write <<~EOS
      bin_PROGRAMS = test
      test_SOURCES = test.c
    EOS
    system bin/"aclocal"
    system bin/"automake", "--add-missing", "--foreign"
    system "autoconf"
    system "./configure"
    system "make"
    system "./test"
  end
end
