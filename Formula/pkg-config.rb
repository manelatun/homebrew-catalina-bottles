# SHA256:j0sjscJfArh95ox6vv78T3oCGSk+PIvpo6XcdMa7OOA=

class PkgConfig < Formula
  desc "Manage compile and link flags for libraries"
  homepage "https://freedesktop.org/wiki/Software/pkg-config/"
  url "https://pkgconfig.freedesktop.org/releases/pkg-config-0.29.2.tar.gz"
  mirror "http://fresh-center.net/linux/misc/pkg-config-0.29.2.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/pkg-config-0.29.2.tar.gz"
  sha256 "6fc69c01688c9458a57eb9a1664c9aba372ccda420a02bf4429fe610e7e7d591"
  license "GPL-2.0-or-later"
  revision 3

  livecheck do
    url "https://pkg-config.freedesktop.org/releases/"
    regex(/href=.*?pkg-config[._-]v?(\d+(?:\.\d+)+)\./i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 catalina: "6a7745d38b75e9ecbe375e1b82d7d0efb4c9c4a8de1a64c312fad0e93edfc929"
  end

  conflicts_with "pkgconf", because: "both install `pkg.m4` file"

  # FIXME: The bottle is mistakenly considered relocatable on Linux.
  # See https://github.com/Homebrew/homebrew-core/pull/85032.
  pour_bottle? only_if: :default_prefix

  def install
    pc_path = %W[
      #{HOMEBREW_PREFIX}/lib/pkgconfig
      #{HOMEBREW_PREFIX}/share/pkgconfig
    ]
    pc_path << if OS.mac?
      system_include_path = "#{MacOS.sdk_path_if_needed}/usr/include"

      pc_path << "/usr/local/lib/pkgconfig"
      pc_path << "/usr/lib/pkgconfig"
      "#{HOMEBREW_LIBRARY}/Homebrew/os/mac/pkgconfig/#{MacOS.version}"
    else
      system_include_path = "/usr/include"

      "#{HOMEBREW_LIBRARY}/Homebrew/os/linux/pkgconfig"
    end

    pc_path = pc_path.uniq.join(File::PATH_SEPARATOR)

    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}",
                          "--disable-host-tool",
                          "--with-internal-glib",
                          "--with-pc-path=#{pc_path}",
                          "--with-system-include-path=#{system_include_path}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"foo.pc").write <<~EOS
      prefix=/usr
      exec_prefix=${prefix}
      includedir=${prefix}/include
      libdir=${exec_prefix}/lib

      Name: foo
      Description: The foo library
      Version: 1.0.0
      Cflags: -I${includedir}/foo
      Libs: -L${libdir} -lfoo
    EOS

    ENV["PKG_CONFIG_LIBDIR"] = testpath
    system bin/"pkg-config", "--validate", "foo"
    assert_equal "1.0.0\n", shell_output("#{bin}/pkg-config --modversion foo")
    assert_equal "-lfoo\n", shell_output("#{bin}/pkg-config --libs foo")
    assert_equal "-I/usr/include/foo\n", shell_output("#{bin}/pkg-config --cflags foo")
  end
end
