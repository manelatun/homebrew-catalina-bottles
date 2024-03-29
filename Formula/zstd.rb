# SHA256:deg90NJLRHDSylZpAat/ys4lrD2jCCpw+4CwGr76Sgk=

class Zstd < Formula
  desc "Zstandard is a real-time compression algorithm"
  homepage "https://facebook.github.io/zstd/"
  url "https://github.com/facebook/zstd/archive/refs/tags/v1.5.5.tar.gz"
  mirror "http://fresh-center.net/linux/misc/zstd-1.5.5.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/zstd-1.5.5.tar.gz"
  sha256 "98e9c3d949d1b924e28e01eccb7deed865eefebf25c2f21c702e5cd5b63b85e1"
  license "BSD-3-Clause"
  head "https://github.com/facebook/zstd.git", branch: "dev"

  # The upstream repository contains old, one-off tags (5.5.5, 6.6.6) that are
  # higher than current versions, so we check the "latest" release instead.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/p0ttrmkd/"
    rebuild 2
    sha256 cellar: :any, catalina: "575879671fe7c23be74f5a1863e4c92f4c44db99c3dff882302bfbfbc42c0e61"
  end

  depends_on "manelatun/catalina-bottles/cmake" => :build
  depends_on "manelatun/catalina-bottles/lz4"
  depends_on "manelatun/catalina-bottles/xz"
  uses_from_macos "zlib"

  def install
    # Legacy support is the default after
    # https://github.com/facebook/zstd/commit/db104f6e839cbef94df4df8268b5fecb58471274
    # Set it to `ON` to be explicit about the configuration.
    system "cmake", "-S", "build/cmake", "-B", "builddir",
                    "-DZSTD_PROGRAMS_LINK_SHARED=ON", # link `zstd` to `libzstd`
                    "-DZSTD_BUILD_CONTRIB=ON",
                    "-DCMAKE_INSTALL_RPATH=#{rpath}",
                    "-DZSTD_LEGACY_SUPPORT=ON",
                    "-DZSTD_ZLIB_SUPPORT=ON",
                    "-DZSTD_LZMA_SUPPORT=ON",
                    "-DZSTD_LZ4_SUPPORT=ON",
                    "-DCMAKE_CXX_STANDARD=11",
                    *std_cmake_args
    system "cmake", "--build", "builddir"
    system "cmake", "--install", "builddir"

    # Prevent dependents from relying on fragile Cellar paths.
    # https://github.com/ocaml/ocaml/issues/12431
    inreplace lib/"pkgconfig/libzstd.pc", prefix, opt_prefix
  end

  test do
    [bin/"zstd", bin/"pzstd", "xz", "lz4", "gzip"].each do |prog|
      data = "Hello, #{prog}"
      assert_equal data, pipe_output("#{bin}/zstd -d", pipe_output(prog, data))
      if prog.to_s.end_with?("zstd")
        # `pzstd` can only decompress zstd-compressed data.
        assert_equal data, pipe_output("#{bin}/pzstd -d", pipe_output(prog, data))
      else
        assert_equal data, pipe_output("#{prog} -d", pipe_output("#{bin}/zstd --format=#{prog}", data))
      end
    end
  end
end
