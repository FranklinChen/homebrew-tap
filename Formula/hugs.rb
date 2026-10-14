class Hugs < Formula
  desc "Haskell implementation called Hugs"
  homepage "https://www.haskell.org/hugs/"
  head "https://github.com/FranklinChen/hugs98-plus-Sep2006.git", branch: "master"
  # No `license` stanza yet: the Hugs core is under a BSD-style license (see the
  # fork's `License` file), but the hugs98-plus bundle also ships libraries
  # under other terms (HaXml, for one, is LGPL). Writing `license all_of: [...]`
  # needs a per-package audit of `packages/*`, which has not been done.

  # No freealut: the OpenAL and ALUT packages cannot build on macOS. In
  # packages/OpenAL/configure.ac the library search (openal, openal32) runs
  # before the darwin case adds OpenAL.framework, so it never links the
  # framework and the package skips itself; ALUT imports it.
  depends_on "libx11"
  depends_on "readline"

  def install
    # The CFLAGS and `make -o configure` below mirror the fork's own
    # tools/ci/build.sh. Each works around a defect in the fork, not in this
    # formula; the comments say what fork change would retire it.

    # Hugs is K&R C, which C23 removed. The fork's configure (autoconf 2.73)
    # switches to -std=gnu23 when clang supports it, and every K&R definition
    # then fails ("unknown type name"). An explicit -std makes that probe fail.
    # Retired by: ac_cv_prog_cc_c23=no in configure.ac, or prototypes.
    ENV["CFLAGS"] = "-std=gnu17 -Wno-error=implicit-function-declaration -Wno-error=implicit-int"

    # The default library search path (configure.ac, every Unix) checks
    # /usr/local/lib/hugs/packages BEFORE this install's {Hugs}/packages, so
    # an older Hugs left in /usr/local silently shadows these libraries. If the
    # fork drops that entry, this inreplace stops matching and fails loudly.
    inreplace "configure",
              'HUGSPATH=".:{Home}/lib/hugs/packages/*:/usr/local/lib/hugs/packages/*:{Hugs}/packages/*"',
              'HUGSPATH=".:{Home}/lib/hugs/packages/*:{Hugs}/packages/*"'

    system "./configure", "--prefix=#{prefix}"

    # The top-level Makefile remakes `configure` (autoreconf) whenever it looks
    # older than its inputs, which depends only on git's checkout order, then
    # re-runs ./configure WITHOUT --prefix, so `make install` targets
    # /usr/local. `-o configure` marks it up to date, so autoconf never runs.
    # Retired by: `./config.status --recheck` in the Makefile's src/Makefile
    # rule, and no automatic regeneration of the committed configure.
    system "make", "-o", "configure"
    system "make", "-o", "configure", "install"
  end

  test do
    # Search only this installation's libraries, so the test cannot pass on
    # the strength of some other Hugs's packages.
    runhugs = "#{bin}/runhugs -98 '-P{Hugs}/packages/*'"

    # Sorting the characters of "Hello, world!" by code point exercises the
    # standard library, not just startup.
    (testpath/"hello.hs").write <<~EOS
      import Data.List (sort)

      main :: IO ()
      main = putStrLn (sort "Hello, world!")
    EOS
    assert_equal " !,Hdellloorw\n", shell_output("#{runhugs} #{testpath}/hello.hs")

    # A package whose library is missing is skipped silently at build time,
    # yet can still install its sources, so only loading a module proves the
    # package built. This list is the fork's own tools/ci/check.py list
    # (non-Windows, graphics included) minus Sound.OpenAL and Sound.ALUT.
    %w[
      Data.List Data.Map Foreign.C.Types System.Directory Network.Socket
      Data.Time.Clock.POSIX Test.HUnit Test.QuickCheck
      Text.ParserCombinators.Parsec Control.Monad.State Data.Graph.Inductive
      Distribution.Simple Language.Haskell.Parser Text.XML.HaXml
      Control.Concurrent.STM Text.XHtml System.Posix.Files
      Graphics.X11.Xlib Graphics.HGL Graphics.Rendering.OpenGL Graphics.UI.GLUT
    ].each do |mod|
      # One file per module: Homebrew's Pathname#write refuses to overwrite.
      program = testpath/"Load_#{mod.tr(".", "_")}.hs"
      program.write <<~EOS
        import qualified #{mod}

        main :: IO ()
        main = putStrLn "loaded"
      EOS
      assert_equal "loaded\n", shell_output("#{runhugs} #{program}"), mod
    end
  end
end
