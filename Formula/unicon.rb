class Unicon < Formula
  desc "Very high level, goal-directed, object-oriented programming language"
  homepage "https://github.com/uniconproject/unicon"
  url "https://github.com/uniconproject/unicon/archive/refs/tags/13.2.tar.gz"
  sha256 "0d0be976f12e3cc3067a4949d8f8a7e4a95368dfd015c43c2c76bc4f83fd0039"
  license "GPL-2.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "freetype"
  depends_on "libjpeg"
  depends_on "libpng"
  depends_on "libx11"
  depends_on "libxft"
  depends_on "libxpm"
  depends_on "openssl"

  conflicts_with "icon", because: "both install `icont` and `iconx` binaries"

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-graphics3d",
      "--disable-audio",
      "--disable-voip",
      "--disable-database",
      "CC=clang",
      "CXX=clang++",
    ]

    system "./configure", *args
    system "make", "-j#{ENV.make_jobs}"
    system "make", "install"

    # patchstr modifies Mach-O binaries after linking to embed install paths,
    # which invalidates their ad-hoc code signatures. Re-sign them so macOS
    # does not SIGKILL them. Also replace icode programs (shell scripts with
    # embedded bytecode) with wrappers, since iconx cannot read icode through
    # Homebrew's Cellar-to-prefix symlinks.
    Dir[bin/"*"].each do |f|
      next if !File.file?(f) || File.symlink?(f)

      mime = `file -b #{f}`
      if mime.include?("Mach-O")
        system "codesign", "-fs", "-", f
      elsif File.open(f, "rb") { |io| io.read(512) }&.include?("executable Icon binary follows")
        real = "#{f}.real"
        mv f, real
        Pathname.new(f).write <<~BASH
          #!/bin/bash
          exec "#{bin}/iconx" "#{real}" "$@"
        BASH
        chmod 0755, f
      end
    end
  end

  def caveats
    <<~EOS
      Unicon is built with 2D graphics support via Homebrew's X11 libraries.
      3D graphics (OpenGL) support requires XQuartz:
        brew install --cask xquartz
    EOS
  end

  test do
    (testpath/"hello.icn").write <<~EOS
      procedure main()
        write("Hello from Unicon!")
      end
    EOS

    system bin/"unicon", "-s", "hello.icn"
    assert_equal "Hello from Unicon!\n", shell_output("#{testpath}/hello")
  end
end
