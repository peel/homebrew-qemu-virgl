class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  url "https://github.com/akihikodaki/virglrenderer.git", revision: "a4e3f13ca2fdf71a55df2ba218ab530755e5e87b"
  version "20230107.1"
  license "MIT"

  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/2023-01-18"
    rebuild 1
    sha256 cellar: :any, arm64_ventura: "b574076ea9688be0f2c68aa189ae879a3e94e40eaf6b587821f140fd0837ec3f"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "akirakyle/qemu-virgl/libepoxy-angle"

  def install
    mkdir "build" do
      system "meson", *std_meson_args,
             "-Dc_args=-I#{Formula["libepoxy-angle"].opt_prefix}/include",
             "-Dc_link_args=-L#{Formula["libepoxy-angle"].opt_prefix}/lib", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    system "true"
  end
end
