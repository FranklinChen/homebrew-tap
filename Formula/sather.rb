class Sather < Formula
  desc "Object-oriented language designed to be simple, efficient, and safe"
  homepage "https://www.gnu.org/software/sather/"
  url "https://ftp.nluug.nl/gnu/sather/sather-1.2.3.tar.gz"
  sha256 "1c95ecd4c081693b0acfd5d6da05efb3e98e2146510f0818342fd9b5995c8bb2"
  license "GPL-3.0-or-later"

  depends_on "bdw-gc"

  def install
    gc = Formula["bdw-gc"]

    # macOS does not have /lib/cpp; use cc -E instead
    inreplace "Makefile" do |s|
      s.gsub! "CPP=/lib/cpp -C -P", "CPP=cc -E -C -P"
      s.gsub! "CC=gcc", "CC=cc"
      s.gsub!(/^PLATFORMS=linux$/, "PLATFORMS=freebsd")
      s.gsub! "DEFAULT_PLATFORM=linux", "DEFAULT_PLATFORM=freebsd"
    end

    # macOS does not have <values.h>
    inreplace "System/Common/c_header.h",
      "!defined(__FreeBSD__) && !defined(__CYGWIN32__)",
      "!defined(__FreeBSD__) && !defined(__APPLE__) && !defined(__CYGWIN32__)"

    # macOS /bin/sh echo does not support -n; use printf
    inreplace "System/Common/Makefile" do |s|
      s.gsub! "@echo -n \"#define", "@printf \"%s\" \"#define"
      s.gsub! "@echo -n                           $(PLATFORMS)", "@printf \"%s\" \"$(PLATFORMS)\""
    end

    # Point boot compiler at Homebrew's bdw-gc and suppress warnings from old C code
    inreplace "Boot/sacomp.code/Makefile" do |s|
      s.gsub! "CFLAGS = -I.  -O2  -I../System/Common",
              "CFLAGS = -I. -O2 -I../System/Common -I#{gc.include} " \
              "-Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-type"
      s.gsub! "LIBS   = -lgc -lm", "LIBS   = -L#{gc.lib} -lgc -lm"
    end

    # Point runtime platform at Homebrew's bdw-gc and suppress warnings
    inreplace "System/Platforms/freebsd/CONFIG" do |s|
      s.gsub! 'CC_OPTIONS:	"-I/usr/local/include";',
              "CC_OPTIONS:\t\"-I#{gc.include} -Wno-implicit-function-declaration " \
              "-Wno-implicit-int -Wno-return-type\";"
      s.gsub! 'GC_LINK:	"-L/usr/local/lib -lgc";',
              "GC_LINK:\t\"-L#{gc.lib} -lgc\";"
    end

    system "make", "small", "SATHER_HOME=#{buildpath}"

    man1.install "Doc/man/man1/sacomp.1"

    # Sather expects SATHER_HOME to contain System/, Library/, etc.
    # Install the distribution tree into libexec.
    libexec.install "Bin", "Boot", "System", "Library", "pLibrary", "Compiler", "Doc"

    # Create a wrapper script that sets SATHER_HOME
    (bin/"sacomp").write <<~BASH
      #!/bin/bash
      export SATHER_HOME="#{libexec}"
      exec "#{libexec}/Bin/sacomp" "$@"
    BASH
  end

  test do
    (testpath/"hello.sa").write <<~SATHER
      class MAIN is
        main is
          #OUT + "Hello from Sather!\\n";
        end;
      end;
    SATHER

    system bin/"sacomp", testpath/"hello.sa", "-o", testpath/"hello"
    assert_equal "Hello from Sather!\n", shell_output("#{testpath}/hello")
  end
end
