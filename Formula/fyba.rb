class Fyba < Formula
  desc "Library to read/write Norwegian National geodata standard (SOSI) files"
  homepage "https://github.com/kartverket/fyba"
  url "https://github.com/kartverket/fyba/archive/4.1.1.tar.gz"
  sha256 "99f658d52e8fd8997118bb6207b9c121500700996d9481a736683474e2534179"

  bottle do
    root_url "https://osgeo4mac.s3.amazonaws.com/bottles"
    cellar :any
    rebuild 1
    sha256 "360465bd604a2ef3c672c86664903a40cc216f6b55b3e7ff2f25ae67ac57ea2f" => :high_sierra
    sha256 "360465bd604a2ef3c672c86664903a40cc216f6b55b3e7ff2f25ae67ac57ea2f" => :sierra
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  def install
    # fixup some includes: https://github.com/kartverket/fyba/issues/12
    # done with inreplace due to CRLF endings in src/UT files
    # REMOVE ON NEXT RELEASE
    %w[configure configure.ac src/UT/DISKINFO.cpp src/UT/INQSIZE.cpp src/UT/INQTID.cpp].each do |s|
      inreplace s, "sys/vfs.h", "sys/mount.h"
    end

    # fixup UT_INT64 type in include: https://github.com/kartverket/fyba/pull/19
    # done with inreplace due to CRLF endings in files
    inreplace "src/UT/fyut.h", %r{(/\* For UNIX \*/)},
        "\\1\r\n#  ifdef __APPLE__\r\n#    include <stdint.h>\r\n#    define UT_INT64 int64_t\r\n#  endif\r\n"

    system "autoreconf", "-vfi"

    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"fyba_test.cpp").write <<-EOS
    #include "fyba.h"
    int main() {
      SK_EntPnt_FYBA char *LC_InqVer(void);
      return 0;
    }
    EOS
    system ENV.cxx, "-I#{include}/fyba", "-L#{lib}", "-lfyba",
           "-lfygm", "-lfyut", "-o", "fyba_test", "fyba_test.cpp"
    system "./fyba_test"
  end
end
