# SHA256:2pRQ3NSRK+lXuVJ1BtWSXZmNu1ORRkZ4sWphmFe8aM8=

class Gnupg < Formula
  desc "GNU Pretty Good Privacy (PGP) package"
  homepage "https://gnupg.org/"
  url "https://gnupg.org/ftp/gcrypt/gnupg/gnupg-2.4.5.tar.bz2"
  sha256 "f68f7d75d06cb1635c336d34d844af97436c3f64ea14bcb7c869782f96f44277"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://gnupg.org/ftp/gcrypt/gnupg/"
    regex(/href=.*?gnupg[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/had3lg6z"
    rebuild 1
    sha256 catalina: "f6eea1fde44df724272d3a1bb73fa9e72b6d128605d16ebec2fd748e5cded2a6"
  end

  depends_on "manelatun/catalina-bottles/pkg-config" => :build
  depends_on "manelatun/catalina-bottles/gnutls"
  depends_on "manelatun/catalina-bottles/libassuan"
  depends_on "manelatun/catalina-bottles/libgcrypt"
  depends_on "manelatun/catalina-bottles/libgpg-error"
  depends_on "manelatun/catalina-bottles/libksba"
  depends_on "manelatun/catalina-bottles/libusb"
  depends_on "manelatun/catalina-bottles/npth"
  depends_on "manelatun/catalina-bottles/openldap"
  depends_on "manelatun/catalina-bottles/pinentry"
  depends_on "manelatun/catalina-bottles/readline"

  uses_from_macos "bzip2"
  uses_from_macos "sqlite", since: :catalina
  uses_from_macos "zlib"

  on_macos do
    depends_on "manelatun/catalina-bottles/gettext"
  end

  def install
    libusb = Formula["libusb"]
    ENV.append "CPPFLAGS", "-I#{libusb.opt_include}/libusb-#{libusb.version.major_minor}"

    mkdir "build" do
      system "../configure", *std_configure_args,
                             "--disable-silent-rules",
                             "--sysconfdir=#{etc}",
                             "--enable-all-tests",
                             "--with-pinentry-pgm=#{Formula["pinentry"].opt_bin}/pinentry"
      system "make"
      system "make", "check"
      system "make", "install"
    end

    # Configure scdaemon as recommended by upstream developers
    # https://dev.gnupg.org/T5415#145864
    if OS.mac?
      # write to buildpath then install to ensure existing files are not clobbered
      (buildpath/"scdaemon.conf").write <<~EOS
        disable-ccid
      EOS
      pkgetc.install "scdaemon.conf"
    end
  end

  def post_install
    (var/"run").mkpath
    quiet_system "killall", "gpg-agent"
  end

  test do
    (testpath/"batch.gpg").write <<~EOS
      Key-Type: RSA
      Key-Length: 2048
      Subkey-Type: RSA
      Subkey-Length: 2048
      Name-Real: Testing
      Name-Email: testing@foo.bar
      Expire-Date: 1d
      %no-protection
      %commit
    EOS
    begin
      system bin/"gpg", "--batch", "--gen-key", "batch.gpg"
      (testpath/"test.txt").write "Hello World!"
      system bin/"gpg", "--detach-sign", "test.txt"
      system bin/"gpg", "--verify", "test.txt.sig"
    ensure
      system bin/"gpgconf", "--kill", "gpg-agent"
    end
  end
end
