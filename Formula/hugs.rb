class Hugs < Formula
  desc "Haskell implementation called Hugs"
  homepage "https://www.haskell.org/hugs/"
  head "https://github.com/FranklinChen/hugs98-plus-Sep2006.git"

  depends_on "readline"
  depends_on "libx11" => :recommended
  depends_on "freealut" => :recommended

  def install
    ENV["CFLAGS"] = "-Wno-error=implicit-function-declaration"
    ENV["LDFLAGS"] = "-L/usr/local/opt/freealut/lib"
    ENV["CPPFLAGS"] = "-I/usr/local/opt/freealut/include"
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
