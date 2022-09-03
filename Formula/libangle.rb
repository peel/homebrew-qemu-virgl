class Libangle < Formula
  desc "Conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android"
  homepage "https://github.com/google/angle"
  url "https://github.com/google/angle.git", using: :git, revision: "4a65a669e11bd7bfa9d77cbf7001836379ec29b5"
  version "20220804.1"
  license "BSD-3-Clause"

  # relocation fails in replace_command with HeaderPadError in macho_file.rb
  # this issue may be related https://github.com/Homebrew/brew/issues/12832
  # this should fix the bottling: https://github.com/Homebrew/brew/issues/4979
  # this seems like a similar error: https://github.com/knazarov/homebrew-qemu-virgl/issues/91
  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/v1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "45576813b1425175f7a3cb9aedae4d3180401ac98f8a9cb2a947fba305604578"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build

  resource "depot_tools" do
    url "https://chromium.googlesource.com/chromium/tools/depot_tools.git", revision: "138bff2823590b3f3db440425bf712392defb7de"
  end

  def install
    mkdir "build" do
      resource("depot_tools").stage do
        path = PATH.new(ENV["PATH"], Dir.pwd)
        with_env(PATH: path) do
          Dir.chdir(buildpath)
          ENV["DEPOT_TOOLS_UPDATE"] = "0"

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
          # "--no-history", "--shallow",

          system "sed", "-i", "-e", "1182i\\
          \"-Wl,-headerpad_max_install_names\",
          ", "BUILD.gn"
          system "gn", "gen", \
                 "--args=is_debug=false", \
                 "./angle_build"
          system "ninja", "-C", "angle_build"
          lib.install "angle_build/libEGL.dylib"
          lib.install "angle_build/libGLESv2.dylib"
          include.install Pathname.glob("include/*")
        end
      end
    end
  end

  test do
    system "true"
  end
end
