# SHA256:uW64RTm20SFoHRBYmbrftBw2yDlFHzlgtCeGXgeM/xI=

class Rust < Formula
  desc "Safe, concurrent, practical language"
  homepage "https://www.rust-lang.org/"
  license any_of: ["Apache-2.0", "MIT"]

  stable do
    url "https://static.rust-lang.org/dist/rustc-1.76.0-src.tar.gz"
    sha256 "9e5cff033a7f0d2266818982ad90e4d3e4ef8f8ee1715776c6e25073a136c021"

    # From https://github.com/rust-lang/rust/tree/#{version}/src/tools
    resource "cargo" do
      url "https://github.com/rust-lang/cargo/archive/refs/tags/0.77.0.tar.gz"
      sha256 "1c33e2feb197f848f082fdc074162328e231c2f68394e0e1d2dbbbf79c9fc3ec"
    end
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/p0ttrmkd/"
    rebuild 1
    sha256 cellar: :any, catalina: "355f8093aca917703ce4f76f82daa8cb2bf4e27926e9e640c00dac18093e1594"
  end

  head do
    url "https://github.com/rust-lang/rust.git", branch: "master"

    resource "cargo" do
      url "https://github.com/rust-lang/cargo.git", branch: "master"
    end
  end

  depends_on "manelatun/catalina-bottles/libgit2"
  depends_on "manelatun/catalina-bottles/libssh2"
  depends_on "manelatun/catalina-bottles/llvm"
  depends_on macos: :sierra
  depends_on "manelatun/catalina-bottles/openssl@3"
  depends_on "manelatun/catalina-bottles/pkg-config"

  uses_from_macos "python" => :build
  uses_from_macos "curl"
  uses_from_macos "zlib"

  # From https://github.com/rust-lang/rust/blob/#{version}/src/stage0.json
  resource "cargobootstrap" do
    on_macos do
      on_arm do
        url "https://static.rust-lang.org/dist/2023-12-28/cargo-1.75.0-aarch64-apple-darwin.tar.xz"
        sha256 "86320d22c192b7a531daed941bbc11d8c7d01b6490cb4b85e7aa7ff92b5baf65"
      end
      on_intel do
        url "https://static.rust-lang.org/dist/2023-12-28/cargo-1.75.0-x86_64-apple-darwin.tar.xz"
        sha256 "08c594b582141bfb3113b4325f567abe1cae5d5e075b0b2b56553f8bc59486b5"
      end
    end

    on_linux do
      on_arm do
        url "https://static.rust-lang.org/dist/2023-12-28/cargo-1.75.0-aarch64-unknown-linux-gnu.tar.xz"
        sha256 "cf367bccbc97ba86b4cf8a0141c9c270523e38f865dc7220b3cfdd79b67200ed"
      end
      on_intel do
        url "https://static.rust-lang.org/dist/2023-12-28/cargo-1.75.0-x86_64-unknown-linux-gnu.tar.xz"
        sha256 "6ac164e7da969a1d524f747f22792e9aa08bc7446f058314445a4f3c1d31a6bd"
      end
    end
  end

  def install
    # Ensure that the `openssl` crate picks up the intended library.
    # https://docs.rs/openssl/latest/openssl/#manual
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix

    ENV["LIBGIT2_NO_VENDOR"] = "1"
    ENV["LIBSSH2_SYS_USE_PKG_CONFIG"] = "1"

    if OS.mac?
      # Requires the CLT to be the active developer directory if Xcode is installed
      ENV["SDKROOT"] = MacOS.sdk_path
      # Fix build failure for compiler_builtins "error: invalid deployment target
      # for -stdlib=libc++ (requires OS X 10.7 or later)"
      ENV["MACOSX_DEPLOYMENT_TARGET"] = MacOS.version
    end

    resource("cargobootstrap").stage do
      system "./install.sh", "--prefix=#{buildpath}/cargobootstrap"
    end
    ENV.prepend_path "PATH", buildpath/"cargobootstrap/bin"

    cargo_src_path = buildpath/"src/tools/cargo"
    cargo_src_path.rmtree
    resource("cargo").stage cargo_src_path
    if OS.mac?
      inreplace cargo_src_path/"Cargo.toml",
                /^curl\s*=\s*"(.+)"$/,
                'curl = { version = "\\1", features = ["force-system-lib-on-osx"] }'
    end

    # rustfmt and rust-analyzer are available in their own formulae.
    tools = %w[
      analysis
      cargo
      clippy
      rustdoc
      rust-analyzer-proc-macro-srv
      rust-demangler
      src
    ]
    args = %W[
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --tools=#{tools.join(",")}
      --llvm-root=#{Formula["llvm"].opt_prefix}
      --enable-llvm-link-shared
      --enable-vendor
      --disable-cargo-native-static
      --enable-profiler
      --set=rust.jemalloc
      --release-description=#{tap.user}
    ]
    if build.head?
      args << "--disable-rpath"
      args << "--release-channel=nightly"
    else
      args << "--release-channel=stable"
    end

    system "./configure", *args
    system "make"
    system "make", "install"

    (lib/"rustlib/src/rust").install "library"
    rm_f [
      bin.glob("*.old"),
      lib/"rustlib/install.log",
      lib/"rustlib/uninstall.sh",
      (lib/"rustlib").glob("manifest-*"),
    ]
  end

  def post_install
    Dir["#{lib}/rustlib/**/*.dylib"].each do |dylib|
      chmod 0664, dylib
      MachO::Tools.change_dylib_id(dylib, "@rpath/#{File.basename(dylib)}")
      MachO.codesign!(dylib) if Hardware::CPU.arm?
      chmod 0444, dylib
    end
  end

  def check_binary_linkage(binary, library)
    binary.dynamically_linked_libraries.any? do |dll|
      next false unless dll.start_with?(HOMEBREW_PREFIX.to_s)

      File.realpath(dll) == File.realpath(library)
    end
  end

  test do
    system bin/"rustdoc", "-h"
    (testpath/"hello.rs").write <<~EOS
      fn main() {
        println!("Hello World!");
      }
    EOS
    system bin/"rustc", "hello.rs"
    assert_equal "Hello World!\n", shell_output("./hello")
    system bin/"cargo", "new", "hello_world", "--bin"
    assert_equal "Hello, world!", cd("hello_world") { shell_output("#{bin}/cargo run").split("\n").last }

    # We only check the tools' linkage here. No need to check rustc.
    expected_linkage = {
      bin/"cargo" => [
        Formula["libgit2"].opt_lib/shared_library("libgit2"),
        Formula["libssh2"].opt_lib/shared_library("libssh2"),
        Formula["openssl@3"].opt_lib/shared_library("libcrypto"),
        Formula["openssl@3"].opt_lib/shared_library("libssl"),
      ],
    }
    unless OS.mac?
      expected_linkage[bin/"cargo"] += [
        Formula["curl"].opt_lib/shared_library("libcurl"),
        Formula["zlib"].opt_lib/shared_library("libz"),
      ]
    end
    missing_linkage = []
    expected_linkage.each do |binary, dylibs|
      dylibs.each do |dylib|
        next if check_binary_linkage(binary, dylib)

        missing_linkage << "#{binary} => #{dylib}"
      end
    end
    assert missing_linkage.empty?, "Missing linkage: #{missing_linkage.join(", ")}"
  end
end
