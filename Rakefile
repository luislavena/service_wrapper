require File.expand_path("rakehelp/freebasic", File.dirname(__FILE__))
require "rake/packagetask"

PRODUCT_NAME = "service_wrapper"
PRODUCT_VERSION = "0.0.1"
PRODUCT_RELEASE = "#{PRODUCT_NAME}-#{PRODUCT_VERSION}-win32.zip"

defaults = {
  :mt       => true,                       # we require multithread
  :pedantic => true,                       # noisy warnings
  :trace    => ENV.fetch("TRACE", false),  # generate a log file
  :debug    => ENV.fetch("DEBUG", false)   # optional debugging
}

project_task "service_wrapper" do
  executable  "service_wrapper"
  build_to    "bin"

  if defaults[:trace]
    define "_TRACE_FILE"
  end

  search_path "inc"
  search_path "vendor/mini_service/inc"

  lib_path    "vendor/mini_service/lib/win32"

  main        "src/service_wrapper.bas"

  library     "mini_service"

  option defaults
end

project_task "test_runner" do
  executable  "runner"
  build_to    "test"

  search_path "inc"
  search_path "vendor/mini_service/inc"

  lib_path    "vendor/mini_service/lib/win32"

  main        "test/helper.bas"
  source      "test/test_*.bas"

  source      "src/configuration_file.bas"
  source      "src/console_process.bas"

  library     "mini_service"

  option defaults
end

namespace "lib" do
  mini_service_dir  = "vendor/mini_service"
  mini_service_rake = File.join(mini_service_dir, "Rakefile")
  mini_service_lib  = File.join(mini_service_dir, "lib", "win32", "libmini_service.a")

  desc "Build mini_service library (dependency)"
  task "mini_service" => [mini_service_lib]

  file mini_service_lib => [mini_service_rake] do
    chdir mini_service_dir do
      ruby "-S rake lib:build"
    end
  end

  file mini_service_rake do
    sh "git submodule update --init mini_service"
  end
end

task :build => ["lib:mini_service"]
task :run => ["test_runner:build"] do
  chdir "test" do
    sh "runner.exe"
  end
end

task :rebuild => []
task :clobber => []

task :default => [:build]

# FIXME: Source code package
Rake::PackageTask.new(PRODUCT_NAME, PRODUCT_VERSION) do |pkg|
  pkg.need_zip = true
  pkg.package_files = FileList[
    "examples/*.conf", "inc/*.bi", "src/*.bas",
    "README.md", "LICENSE.txt", "History.txt",
    "rakehelp/freebasic.rb", "Rakefile"
  ]
end

# FIXME: Fix binary package
desc "Build binary packages"
task :release => ["pkg/#{PRODUCT_RELEASE}"]
task :package => [:release]

file "pkg/#{PRODUCT_RELEASE}" => ["pkg"] do |f|
  zipfile = File.basename(f.name)
  dirname = zipfile.gsub(File.extname(zipfile), "")

  base    = File.join("pkg", dirname)
  bin_dir = File.join(base, "bin")
  doc_dir = File.join(base, "docs", PRODUCT_NAME)
  exa_dir = File.join(base, "examples", PRODUCT_NAME)

  mkdir_p bin_dir
  mkdir_p doc_dir
  mkdir_p exa_dir

  cp FileList["bin/*.exe"], bin_dir
  cp "examples/*.conf", exa_dir
  cp "README.md", doc_dir
  cp "History.txt", doc_dir
  cp "LICENSE.txt", doc_dir

  chdir "pkg" do
    sh "zip -r #{zipfile} #{dirname}"
  end
end
