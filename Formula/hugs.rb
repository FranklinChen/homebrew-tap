class Hugs < Formula
  desc "Haskell implementation called Hugs"
  homepage "https://www.haskell.org/hugs/"
  head "https://github.com/FranklinChen/hugs98-plus-Sep2006.git", branch: "master"
  # No `license` stanza yet: the Hugs core is under a BSD-style license (see the
  # fork's `License` file), but the hugs98-plus bundle also ships libraries
  # under other terms (HaXml, for one, is LGPL). Writing `license all_of: [...]`
  # needs a per-package audit of `packages/*`, which has not been done.

  depends_on "autoconf" => :build
  depends_on "freealut"
  depends_on "libx11"
  depends_on "readline"

  def install
    ENV.prepend_path "PATH", formula_opt_bin("autoconf")
    ENV["CFLAGS"] = "-Wno-error=implicit-function-declaration -Wno-error=implicit-int"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"hello.hs").write <<~EOS
      import Data.List (sort)

      main :: IO ()
      main = putStrLn (sort "Hello, world!")
    EOS

    # Sorting the characters of "Hello, world!" by code point exercises the
    # standard library, not just startup.
    assert_equal " !,Hdellloorw\n", shell_output("#{bin}/runhugs #{testpath}/hello.hs")

    # Each package's configure step skips the package silently when its
    # library is not found, so check that the dependencies were really used.
    %w[ALUT X11].each do |package|
      assert_predicate lib/"hugs/packages"/package, :directory?
    end
  end
end
