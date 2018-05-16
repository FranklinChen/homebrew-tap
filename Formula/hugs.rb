class Hugs < Formula
  desc "Haskell implementation called Hugs"
  homepage "https://www.haskell.org/hugs/"
  head "https://github.com/FranklinChen/hugs98-plus-Sep2006.git"

  depends_on "readline"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"hello.hs").write <<-EOS.undent
      import Data.List (sort)

      main :: IO ()
      main = putStrLn (sort "Hello, world!")
    EOS

    system "#{bin}/runhugs", testpath/"hello.hs"
  end
end
