# SHA256:x71uJK4VQxhOglMzt+Q2YacAonjSc7Xf9V9CRyxz+gI=

class Libgit2 < Formula
  desc "C library of Git core methods that is re-entrant and linkable"
  homepage "https://libgit2.github.com/"
  url "https://github.com/libgit2/libgit2/archive/refs/tags/v1.7.2.tar.gz"
  sha256 "de384e29d7efc9330c6cdb126ebf88342b5025d920dcb7c645defad85195ea7f"
  license "GPL-2.0-only" => { with: "GCC-exception-2.0" }
  head "https://github.com/libgit2/libgit2.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/p0ttrmkd/"
    rebuild 1
    sha256 cellar: :any, catalina: "07894944144bde893ff464e82ff98b23ceb5bd55dbb168d98ec92367f4ea43d2"
  end

  depends_on "manelatun/catalina-bottles/cmake" => :build
  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/libssh2"
  depends_on "manelatun/catalina-bottles/openssl@3"

  def install
    args = %w[-DBUILD_EXAMPLES=OFF -DBUILD_TESTS=OFF -DUSE_SSH=ON]

    system "cmake", "-S", ".", "-B", "build", "-DBUILD_SHARED_LIBS=ON", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    system "cmake", "-S", ".", "-B", "build-static", "-DBUILD_SHARED_LIBS=OFF", *args, *std_cmake_args
    system "cmake", "--build", "build-static"
    lib.install "build-static/libgit2.a"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <git2.h>
      #include <assert.h>

      int main(int argc, char *argv[]) {
        int options = git_libgit2_features();
        assert(options & GIT_FEATURE_SSH);
        return 0;
      }
    EOS
    libssh2 = Formula["libssh2"]
    flags = %W[
      -I#{include}
      -I#{libssh2.opt_include}
      -L#{lib}
      -lgit2
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
