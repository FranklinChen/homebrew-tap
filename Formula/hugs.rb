class Hugs < Formula
  desc "Haskell implementation called Hugs"
  homepage "https://www.haskell.org/hugs/"
  head "https://github.com/FranklinChen/hugs98-plus-Sep2006.git", branch: "master"
  # No `license` stanza yet: the Hugs core is under a BSD-style license (see the
  # fork's `License` file), but the hugs98-plus bundle also ships libraries
  # under other terms (HaXml, for one, is LGPL). Writing `license all_of: [...]`
  # needs a per-package audit of `packages/*`, which has not been done.

  depends_on "freealut"
  depends_on "libx11"
  depends_on "readline"

  def install
    # Hugs is pre-ANSI C: keep modern clang from making these errors. They
    # must be in the environment, which is the only way they reach the
    # library packages, each configured and compiled separately.
    ENV["CFLAGS"] = "-Wno-error=implicit-function-declaration -Wno-error=implicit-int"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
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
    # (non-Windows, graphics included).
    %w[
      Data.List Data.Map Foreign.C.Types System.Directory Network.Socket
      Data.Time.Clock.POSIX Test.HUnit Test.QuickCheck
      Text.ParserCombinators.Parsec Control.Monad.State Data.Graph.Inductive
      Distribution.Simple Language.Haskell.Parser Text.XML.HaXml
      Control.Concurrent.STM Text.XHtml System.Posix.Files
      Graphics.X11.Xlib Graphics.HGL Graphics.Rendering.OpenGL Graphics.UI.GLUT
      Sound.OpenAL Sound.ALUT
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
