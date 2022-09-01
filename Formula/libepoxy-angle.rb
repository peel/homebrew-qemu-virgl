class LibepoxyAngle < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  # waiting for upstreaming of https://github.com/akihikodaki/libepoxy/tree/macos
  url "https://github.com/akihikodaki/libepoxy.git", using: :git, revision: "ec54e0ff95dd98cd5d5c62b38d9ae427e4e6e747"
  version "20211208.1"
  license "MIT"

  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/v1"
    sha256 cellar: :any, arm64_monterey: "3fbabe75763e6379178bc3dc52a874f124ca614f54dec421df07c742189df264"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on "akirakyle/qemu-virgl/libangle"

  def install
    mkdir "build" do
      system "meson", *std_meson_args,
             "-Degl=yes", "-Dx11=false", ".."
             #"-Dc_args=-I#{Formula["libangle"].opt_prefix}/include",
             #"-Dc_link_args=-Wl,-rpath,${HOMEBREW_PREFIX}/lib",
             #"-Dc_link_args=-L#{Formula["libangle"].opt_prefix}/lib",
             #"-Dc_link_args=-Wl,-rpath,#{rpath}",
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS

      #include <epoxy/gl.h>
      #include <OpenGL/CGLContext.h>
      #include <OpenGL/CGLTypes.h>
      #include <OpenGL/OpenGL.h>
      int main()
      {
          CGLPixelFormatAttribute attribs[] = {0};
          CGLPixelFormatObj pix;
          int npix;
          CGLContextObj ctx;

          CGLChoosePixelFormat( attribs, &pix, &npix );
          CGLCreateContext(pix, (void*)0, &ctx);

          glClear(GL_COLOR_BUFFER_BIT);
          CGLReleasePixelFormat(pix);
          CGLReleaseContext(pix);
          return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lepoxy", "-framework", "OpenGL", "-o", "test"
    system "ls", "-lh", "test"
    system "file", "test"
    system "./test"
  end
end
