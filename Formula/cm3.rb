class Cm3 < Formula
  desc "Critical Mass Modula-3 compiler and runtime"
  homepage "https://github.com/modula3/cm3"
  url "https://github.com/modula3/cm3/archive/refs/tags/d5.12.1.tar.gz"
  sha256 "a6b160041a9e1ea7049b2c5b244d02e59f4d0dc665e0a2a15cc3ddd2495ea7e3"
  license :cannot_represent

  livecheck do
    url :stable
    regex(/^d?(\d+(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  # The m3odbc package links against iODBC, which macOS SDKs no longer ship.
  depends_on "libiodbc"

  # Transpiled C++ sources of a native Darwin compiler: each asset's
  # CMakeLists.txt sets its own M3Target (ARM64_DARWIN or AMD64_DARWIN).
  #
  # These assets sit on the d5.12.0 release but were generated in May 2026
  # from the post-d5.12.0 tree, in which EXTENDED is 64 bits on every target
  # except AMD64_LINUX (upstream f10c386). The d5.12.0 source still selects
  # 128-bit EXTENDED for Darwin, which this compiler rejects ("LOOPHOLE:
  # expression's size (64) differs from type's (128)"), so the source must be
  # d5.12.1 or later. Upstream's own release build of the d5.12.1 tag
  # (.github/workflows/make-release.yml, run 25555020859) uses exactly this
  # pairing: the d5.12.0 Darwin bootstrap with the d5.12.1 source.
  resource "bootstrap" do
    on_arm do
      url "https://github.com/modula3/cm3/releases/download/d5.12.0/cm3-boot-ARM64_DARWIN-d5.12.0.tar.xz"
      sha256 "597d5a0ca1a91cfe9aee3ee25248d941f021e14d1e81495ab76ac562f5e42f57"
    end
    on_intel do
      url "https://github.com/modula3/cm3/releases/download/d5.12.0/cm3-boot-AMD64_DARWIN-d5.12.0.tar.xz"
      sha256 "6a5c4960a2e51f3c18ce3f660193a4d672255df6debd467d3b86a5f9afbf071c"
    end
  end

  def install
    bootstrap_dir = buildpath/"bootstrap"
    resource("bootstrap").stage(bootstrap_dir)

    # Stage 1: build bootstrap cm3 + mklib from transpiled C++ sources.
    #
    # Everything installs into libexec, not the prefix: cm3 finds its
    # configuration beside its own executable (bin/cm3.cfg sets INSTALL_ROOT
    # to bin/.., then reads bin/config/<TARGET>, pkg/ and lib/), and Homebrew
    # allows only executables in bin. The executables are wrapped below.
    boot_build = buildpath/"boot-build"
    system "cmake", "-S", bootstrap_dir, "-B", boot_build,
           "-G", "Ninja",
           "-DCMAKE_INSTALL_PREFIX=#{libexec}"
    system "cmake", "--build", boot_build
    system "cmake", "--install", boot_build

    # cm3's per-target config names the ODBC libraries, but assumes they are
    # on the default search path: ARM64_DARWIN uses -L/opt/homebrew/lib, and
    # Darwin.common gives AMD64_DARWIN no -L at all. Homebrew's libiodbc is
    # keg-only (it conflicts with unixodbc), so neither finds it. Override the
    # entry at the end of the target's config; stage 2 installs that config
    # into libexec/bin/config, so the installed compiler links ODBC programs.
    (buildpath/"m3-sys/cminstall/src/config"/m3_target).append_lines <<~QUAKE

      % Homebrew override: keg-only libiodbc.
      SYSTEM_LIBS{"ODBC"} = ["-L#{formula_opt_lib("libiodbc")}", "-liodbc", "-liodbcinst"]
    QUAKE

    # concierge overwrites the installed compiler between self-build passes.
    # macOS caches signatures by file identity, so overwriting an executable
    # can SIGKILL the next launch even when its signature is valid on disk.
    # Copy to a fresh file and atomically replace it before running it again.
    # https://developer.apple.com/documentation/security/updating-mac-software
    inreplace "scripts/concierge.py",
              "                self.cp(item, dst)\n            else:",
              [
                "                self.cp(item, dst / (exe + \".new\"))",
                "                if not self.no_action():",
                "                    os.replace(dst / (exe + \".new\"), dst / exe)",
                "            else:",
              ].join("\n")

    # Stage 2: full upgrade from Modula-3 sources (headless, no X11/GUI)
    ENV.prepend_path "PATH", libexec/"bin"
    ENV["CM3_INSTALL"] = libexec.to_s
    system "python3", "scripts/concierge.py", "full-upgrade", "--backend", "c", "headless"

    # Re-sign Mach-O binaries: the build modifies them after linking,
    # invalidating ad-hoc code signatures (same pattern as unicon.rb).
    # safe_popen_read runs `file` without a shell and fails loudly.
    mach_o = Dir[libexec/"{bin,lib}/**/*"].select do |f|
      File.file?(f) && !File.symlink?(f) &&
        Utils.safe_popen_read("file", "-b", f).include?("Mach-O")
    end
    system "codesign", "-fs", "-", *mach_o

    # Wrap every executable in libexec/bin. A wrapper execs the binary by its
    # path, so cm3 finds cm3.cfg beside it; a symlink would leave it looking
    # in Homebrew's bin. The path is the version-independent opt one: cm3
    # bakes INSTALL_ROOT into the rpaths and -L flags of programs it builds,
    # and a Cellar path would break those programs on the next upgrade.
    programs = (libexec/"bin").children.select { |f| f.file? && f.executable? }
    bin.write_exec_script programs.map { |f| opt_libexec/"bin"/f.basename }
    man.install Dir[libexec/"man/*"]
  end

  # The cm3 target name for this Mac; it also names the build output
  # directory, which the test needs.
  def m3_target
    Hardware::CPU.arm? ? "ARM64_DARWIN" : "AMD64_DARWIN"
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
    assert_equal "Hello from CM3!\n", shell_output("#{testpath}/#{m3_target}/hello")
  end
end
