# SHA256:/i+MoZJolEvX+saTorgqA+yrxRiOSrp0JrVjlZkxZyk=

class Certifi < Formula
  desc "Mozilla CA bundle for Python"
  homepage "https://github.com/certifi/python-certifi"
  url "https://files.pythonhosted.org/packages/71/da/e94e26401b62acd6d91df2b52954aceb7f561743aa5ccc32152886c76c96/certifi-2024.2.2.tar.gz"
  sha256 "0569859f95fc761b18b45ef421b1290a0f65f147e92a1e5eb3e635f9a5e4e66f"
  license "MPL-2.0"

  bottle do
    root_url "https://github.com/manelatun/homebrew-catalina-bottles/releases/download/wluewbcs/"
    rebuild 1
    sha256 cellar: :any_skip_relocation, catalina: "a73d2f424602624304c127b13e4a0dda5a5299bf74b19f3f9336619b824d05c7"
  end

  depends_on "manelatun/catalina-bottles/python@3.11" => [:build, :test]
  depends_on "manelatun/catalina-bottles/python@3.12" => [:build, :test]
  depends_on "manelatun/catalina-bottles/ca-certificates"

  def pythons
    deps.map(&:to_formula).sort_by(&:version).filter { |f| f.name.start_with?("python@") }
  end

  def install
    pythons.each do |python|
      python_exe = python.opt_libexec/"bin/python"
      system python_exe, "-m", "pip", "install", *std_pip_args(build_isolation: true), "."

      # Use brewed ca-certificates PEM file instead of the bundled copy
      site_packages = Language::Python.site_packages("python#{python.version.major_minor}")
      rm prefix/site_packages/"certifi/cacert.pem"
      (prefix/site_packages/"certifi").install_symlink Formula["ca-certificates"].pkgetc/"cert.pem" => "cacert.pem"
    end
  end

  test do
    pythons.each do |python|
      python_exe = python.opt_libexec/"bin/python"
      output = shell_output("#{python_exe} -m certifi").chomp
      assert_equal Formula["ca-certificates"].pkgetc/"cert.pem", Pathname(output).realpath
    end
  end
end
