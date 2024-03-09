# SHA256:y+mMQ7rlQMlOjHfNhGG3y2X1LDsyhSiD4osAhz7ldyY=

class Cmake < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3.tar.gz"
  mirror "http://fresh-center.net/linux/misc/cmake-3.28.3.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/cmake-3.28.3.tar.gz"
  sha256 "72b7570e5c8593de6ac4ab433b73eab18c5fb328880460c86ce32608141ad5c1"
  license "BSD-3-Clause"
  head "https://gitlab.kitware.com/cmake/cmake.git", branch: "master"

  # The "latest" release on GitHub has been an unstable version before, and
  # there have been delays between the creation of a tag and the corresponding
  # release, so we check the website's downloads page instead.
  livecheck do
    url "https://cmake.org/download/"
    regex(/href=.*?cmake[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/p0ttrmkd/"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "70ae3f2a590ad7192b1eab081005bd6eae9f7f60aa16641d87587bcdf7274948"
  end

  uses_from_macos "ncurses"

  on_linux do
    depends_on "manelatun/catalina-bottles/openssl@3"
  end

  # The completions were removed because of problems with system bash

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use `brew install --cask cmake`.

  def install
    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]
    if OS.mac?
      args += %w[
        --system-zlib
        --system-bzip2
        --system-curl
      ]
    end

    system "./bootstrap", *args, "--", *std_cmake_args,
                                       "-DCMake_INSTALL_BASH_COMP_DIR=#{bash_completion}",
                                       "-DCMake_INSTALL_EMACS_DIR=#{elisp}",
                                       "-DCMake_BUILD_LTO=ON"
    system "make"
    system "make", "install"
  end

  def caveats
    <<~EOS
      To install the CMake documentation, run:
        brew install cmake-docs
    EOS
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake", "."

    # These should be supplied in a separate cmake-docs formula.
    refute_path_exists doc/"html"
    refute_path_exists man
  end
end
