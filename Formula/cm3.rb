class Cm3 < Formula
  desc "Critical Mass Modula-3 compiler and runtime"
  homepage "https://github.com/modula3/cm3"
  url "https://github.com/modula3/cm3/archive/refs/tags/d5.11.10.tar.gz"
  sha256 "353547eea26d02814c1808f4e8b4b3d15f9cf5dd30a7a3d49884a63475c20cf1"
  license :cannot_represent

  livecheck do
    url :stable
    regex(/^d?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "gnu-tar" => :build
  depends_on "ninja" => :build

  resource "bootstrap" do
    url "https://github.com/modula3/cm3/releases/download/d5.11.10/cm3-boot-AMD64_LINUX-d5.11.10.tar.xz"
    sha256 "9a77e9209b0ea19a0c93706f52a46f0b43e16959c8cf4a4202f9803d179b4170"
  end

  def install
    # Stage bootstrap C++ sources
    bootstrap_dir = buildpath/"bootstrap"
    resource("bootstrap").stage do
      # The bootstrap tarball contains hardlinks that BSD tar cannot handle;
      # if Homebrew's built-in extraction left an empty directory, re-extract
      # with GNU tar.
      if Dir.empty?(Dir.pwd)
        gtar = Formula["gnu-tar"].opt_bin/"gtar"
        cached = resource("bootstrap").cached_download
        mkdir_p bootstrap_dir
        system gtar.to_s, "-xf", cached.to_s, "-C", bootstrap_dir.to_s, "--strip-components=1"
      else
        bootstrap_dir.install Dir["*"]
      end
    end

    # Stage 1: build bootstrap cm3 + mklib from transpiled C++ sources
    boot_build = buildpath/"boot-build"
    system "cmake", "-S", bootstrap_dir, "-B", boot_build,
           "-G", "Ninja",
           "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    system "cmake", "--build", boot_build
    system "cmake", "--install", boot_build

    # Stage 2: full upgrade from Modula-3 sources (headless — no X11/GUI)
    ENV.prepend_path "PATH", bin
    ENV["CM3_INSTALL"] = prefix.to_s
    system "python3", "scripts/concierge.py", "full-upgrade", "--backend", "c", "headless"

    # Re-sign Mach-O binaries — the build modifies them after linking,
    # invalidating ad-hoc code signatures (same pattern as unicon.rb).
    [bin, lib].each do |dir|
      Dir[dir/"**/*"].each do |f|
        next if !File.file?(f) || File.symlink?(f)

        mime = `file -b #{f}`
        system "codesign", "-fs", "-", f if mime.include?("Mach-O")
      end
    end
  end

  def caveats
    <<~EOS
      CM3 is built headless (no X11/GUI packages).
      For GUI support (Trestle, FormsVBT, etc.) you need XQuartz:
        brew install --cask xquartz
    EOS
  end

  test do
    # Create a minimal Modula-3 package
    (testpath/"src").mkpath
    (testpath/"src"/"m3makefile").write <<~M3MAKEFILE
      import("libm3")
      implementation("Hello")
      program("hello")
    M3MAKEFILE
    (testpath/"src"/"Hello.m3").write <<~M3
      MODULE Hello EXPORTS Main;
      IMPORT IO;
      BEGIN
        IO.Put("Hello from CM3!\\n");
      END Hello.
    M3

    system bin/"cm3", "-build"

    # Output lands in a target-specific subdirectory
    target = if Hardware::CPU.arm?
      "ARM64_DARWIN"
    else
      "AMD64_DARWIN"
    end
    assert_equal "Hello from CM3!\n", shell_output("#{testpath}/#{target}/hello")
  end
end
