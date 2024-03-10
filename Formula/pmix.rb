# SHA256:JXzqGBTqgMocBWwszGXWiedlZdM2PqZfmJiFFxf/o64=

class Pmix < Formula
  desc "Process Management Interface for HPC environments"
  homepage "https://openpmix.github.io/"
  url "https://github.com/openpmix/openpmix/releases/download/v4.2.9/pmix-4.2.9.tar.bz2"
  sha256 "6b11f4fd5c9d7f8e55fc6ebdee9af04b839f44d06044e58cea38c87c168784b3"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/oe6mc1h2/"
    rebuild 1
    sha256 catalina: "52fc0db8461d7484af392d954f11d52ee271c5ea14abb3c84a8cec4f6d9682d5"
  end

  head do
    url "https://github.com/openpmix/openpmix.git", branch: "master"

    depends_on "manelatun/catalina-bottles/autoconf" => :build
    depends_on "manelatun/catalina-bottles/automake" => :build
    depends_on "manelatun/catalina-bottles/libtool" => :build
  end

  depends_on "manelatun/catalina-bottles/hwloc"
  depends_on "manelatun/catalina-bottles/libevent"

  uses_from_macos "python" => :build
  uses_from_macos "zlib"

  def install
    # Avoid references to the Homebrew shims directory
    cc = OS.linux? ? "gcc" : ENV.cc
    inreplace "src/tools/pmix_info/support.c", "PMIX_CC_ABSOLUTE", "\"#{cc}\""

    args = %W[
      --disable-silent-rules
      --enable-ipv6
      --sysconfdir=#{etc}
      --with-hwloc=#{Formula["hwloc"].opt_prefix}
      --with-libevent=#{Formula["libevent"].opt_prefix}
      --with-sge
    ]

    system "./autogen.pl", "--force" if build.head?
    system "./configure", *args, *std_configure_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <pmix.h>

      int main(int argc, char **argv) {
        pmix_value_t *val;
        pmix_proc_t myproc;
        pmix_status_t rc;

        return 0;
      }
    EOS

    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpmix", "-o", "test"
    system "./test"

    assert_match "PMIX: #{version}", shell_output("#{bin}/pmix_info --pretty-print")
  end
end
