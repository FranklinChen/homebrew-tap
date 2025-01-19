class Hugs < Formula
  desc "Haskell implementation called Hugs"
  homepage "https://www.haskell.org/hugs/"
  head "https://github.com/FranklinChen/hugs98-plus-Sep2006.git"

  depends_on "autoconf" => :build
  depends_on "readline"
  depends_on "libx11" => :recommended
  depends_on "freealut" => :recommended

  def install
    freealut_prefix = Formula["freealut"].opt_prefix

    ENV.prepend_path "PATH", Formula["autoconf"].opt_bin
    ENV["CFLAGS"] = "-Wno-error=implicit-function-declaration -Wno-error=implicit-int"
    ENV["LDFLAGS"] = "-L#{freealut_prefix}/lib"
    ENV["CPPFLAGS"] = "-I#{freealut_prefix}/include"
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

    system "#{bin}/runhugs", testpath/"hello.hs"
  end
end
