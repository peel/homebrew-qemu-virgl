class Libangle < Formula
  desc "Conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android"
  homepage "https://github.com/google/angle"
  url "https://github.com/akihikodaki/angle", using: :git, revision: "66ab9240d3a5969258e65f2f7fe453e83299aa30"
  version "20221101.1"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/2023-01-18"
    rebuild 1
    sha256 cellar: :any, arm64_ventura: "c2e2863050d23c757ec65513cb22e83e84bc0e1bf83658278fb2fac9f124feb4"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git", revision: "268d645853ee8e1b884260049e5464a5ca2d8a30"
  end

  def install
    mkdir "build" do
      resource("depot_tools").stage do
        path = PATH.new(ENV["PATH"], Dir.pwd)
        with_env(PATH: path) do
          Dir.chdir(buildpath)
          ENV["DEPOT_TOOLS_UPDATE"] = "0"

          # We run this rather than scripts/bootstrap.py
          # so that we can set the cache-dir since depot-tools pulls in a lot!
          system "gclient", "config",
                 "--name", "change2dot",
                 "--unmanaged",
                 "--cache-dir", "#{HOMEBREW_CACHE}/gclient_cache",
                 "-j", ENV.make_jobs,
                 "https://chromium.googlesource.com/angle/angle.git"
          content = File.read(".gclient")
          content = content.gsub(/change2dot/, ".")
          content += "target_os = [ 'android' ]"
          File.open(".gclient", "w") { |file| file.puts content }
          system "gclient", "sync", "-j", ENV.make_jobs

          # This fixes relocation failing with HeaderPadError in
          # replace_command in macho_file.rb
          system "sed", "-i", "-e", "1228i\\
          \"-Wl,-headerpad_max_install_names\",
          ", "BUILD.gn"
          system "gn", "gen", \
                 "--args=is_debug=false", \
                 "./angle_build"
          system "ninja", "-C", "angle_build"
          lib.install "angle_build/libEGL_static.dylib"
          lib.install "angle_build/libGLESv2_static.dylib"
          include.install Pathname.glob("include/*")
        end
      end
    end
  end

  test do
    system "true"
  end
end
