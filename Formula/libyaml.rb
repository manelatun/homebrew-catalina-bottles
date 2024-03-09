# SHA256:Av+vHQRsfhI/i6LR5WrFLn24YgOhB+OAiJ/kfoeHK8o=

class Libyaml < Formula
  desc "YAML Parser"
  homepage "https://github.com/yaml/libyaml"
  url "https://github.com/yaml/libyaml/archive/refs/tags/0.2.5.tar.gz"
  sha256 "fa240dbf262be053f3898006d502d514936c818e422afdcf33921c63bed9bf2e"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/p0ttrmkd/"
    rebuild 1
    sha256 cellar: :any, catalina: "3e68fdde88c86ad3ab7f2d79eabe44aea7adb8cddee2bb3176ba226d3f9e420c"
  end

  depends_on "manelatun/catalina-bottles/autoconf" => :build
  depends_on "manelatun/catalina-bottles/automake" => :build
  depends_on "manelatun/catalina-bottles/libtool" => :build

  def install
    system "./bootstrap"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <yaml.h>

      int main()
      {
        yaml_parser_t parser;
        yaml_parser_initialize(&parser);
        yaml_parser_delete(&parser);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lyaml", "-o", "test"
    system "./test"
  end
end
