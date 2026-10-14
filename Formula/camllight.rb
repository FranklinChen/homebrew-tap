class Camllight < Formula
  desc "Bytecode implementation of Caml, a 1990s ML-family functional language"
  homepage "https://github.com/FranklinChen/camllight"
  # sources/LICENSE: the compiler is under the Q Public License 1.0, the
  # library (runtime, config, contrib, lib) under the GNU Library GPL
  # version 2 (no "or later") with a static-linking exception. That exception
  # is SPDX's OCaml-LGPL-linking-exception except that it still reads
  # "clause 3", the typo OCaml fixed to "clause 2" in 2007, which the SPDX
  # template does not accept, so it is not encoded here.
  license all_of: ["QPL-1.0", "LGPL-2.0-only"]
  head "https://github.com/FranklinChen/camllight.git", branch: "master"

  def install
    # Caml Light is pre-ANSI K&R-era C. Modern clang rejects it by default, so
    # the same warning-suppression flags the project's CI uses are required.
    opts = "-O2 -Wno-implicit-int -Wno-deprecated-non-prototype " \
           "-Wno-pointer-sign -Wno-implicit-function-declaration"

    cd "sources/src" do
      # `configure` probes the host (int/pointer sizes, endianness, libc) and
      # writes ../config/m.h and ../config/s.h.
      system "make", "CC=#{ENV.cc}", "OPTS=#{opts}", "configure"

      # The user-facing wrapper scripts (camlc, camllight, camlmktop) have
      # LIBDIR and CC baked in by sed during the `launch` step of `world`, NOT
      # at install time. So BINDIR/LIBDIR/CC must be set on THIS line, or the
      # installed `camllight` will point -stdlib at /usr/local and break under
      # the Homebrew prefix.
      system "make", "CC=#{ENV.cc}", "OPTS=#{opts}",
             "BINDIR=#{bin}", "LIBDIR=#{lib}/caml-light", "world"

      # `install` copies camlrun and the wrappers into BINDIR, the bytecode
      # standard library into LIBDIR, and the man pages into MANDIR.
      system "make", "BINDIR=#{bin}", "LIBDIR=#{lib}/caml-light",
             "MANDIR=#{man1}", "install"
    end
  end

  test do
    # Mirror the project's own build self-test: fib 20 must evaluate to 10946
    # in the interactive toplevel. The installed `camllight` wrapper already
    # knows its standard library, so no -stdlib flag is needed.
    program = "let rec fib n = if n < 2 then 1 else fib(n-1) + fib(n-2);;\n" \
              "fib 20;;\n"
    assert_match "10946", pipe_output(bin/"camllight", program)
  end
end
