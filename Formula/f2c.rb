class F2c < Formula
  desc "Compiler from Fortran to C"
  homepage "https://www.netlib.org/f2c/"
  url "https://netlib.org/f2c/src.tgz"
  version "20250303"
  sha256 "b2824a6f7b75ffe0193ce9ba55463191a7af7c2ffe10e371e372451e2b527e09"

  resource "libf2c" do
    url "https://netlib.org/f2c/libf2c.zip"
    sha256 "cc84253b47b5c036aa1d529332a6c218a39ff71c76974296262b03776f822695"
  end

  def install
    ENV["CFLAGS"] = "-Wno-error=implicit-function-declaration -Wno-error=implicit-int"

    resource("libf2c").stage do
      system "make", "-f", "makefile.u", "f2c.h"
      include.install "f2c.h"

      system "make", "-f", "makefile.u"
      lib.install "libf2c.a"
    end

    system "make", "-f", "makefile.u", "f2c"
    bin.install "f2c"

    man1.install "f2c.1t"
  end

  test do
    system bin/"f2c", "--version"

    (testpath/"test.f").write <<~EOS
      C comment line
            program hello
            print*, 'hello world'
            stop
            end
    EOS
    system bin/"f2c", "test.f"
    assert_path_exists testpath/"test.c"
    system ENV.cc, "-O", "-o", "test", "test.c", "-L#{lib}", "-I#{include}", "-lf2c"
    assert_equal " hello world\n", shell_output("#{testpath}/test")
  end
end
