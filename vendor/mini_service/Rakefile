require File.expand_path("rakehelp/freebasic", File.dirname(__FILE__))
require "rake/packagetask"

PRODUCT_NAME = "mini_service"
PRODUCT_VERSION = "0.2.0"
PRODUCT_RELEASE = "#{PRODUCT_NAME}-#{PRODUCT_VERSION}-win32.zip"

defaults = {
  :mt       => true,                       # we require multithread
  :pedantic => true,                       # noisy warnings
  :trace    => ENV.fetch("TRACE", false),  # generate a log file
  :debug    => ENV.fetch("DEBUG", false)   # optional debugging
}

namespace "lib" do
  project_task "mini_service" do
    lib "mini_service"
    build_to "lib/win32"

    if defaults[:trace]
      define "_MINI_SERVICE_TRACE_FILE"
    end

    search_path "inc"
    source "src/mini_service.bas"

    library "user32", "advapi32"

    option defaults
  end
end

namespace "examples" do
  task "build" => ["lib:build"]
  project_task "basic" do
    executable  "basic"
    build_to    "examples"

    search_path "inc"
    lib_path    "lib/win32"

    main        "examples/basic.bas"

    library     "mini_service"

    option defaults
  end
end

task :build => ["lib:build", "examples:build"]
task :rebuild => ["lib:rebuild", "examples:rebuild"]
task :clobber => ["lib:clobber", "examples:clobber"]

task :default => [:build]

# Source code package
Rake::PackageTask.new(PRODUCT_NAME, PRODUCT_VERSION) do |pkg|
  pkg.need_zip = true
  pkg.package_files = FileList[
    "examples/*.bas", "inc/*.bi", "src/*.bas",
    "README.md", "LICENSE.txt", "History.txt",
    "rakehelp/freebasic.rb", "Rakefile"
  ]
end

desc "Build binary packages"
task :release => ["pkg/#{PRODUCT_RELEASE}"]
task :package => [:release]

file "pkg/#{PRODUCT_RELEASE}" => ["lib:build", "pkg"] do |f|
  zipfile = File.basename(f.name)
  dirname = zipfile.gsub(File.extname(zipfile), "")

  base    = File.join("pkg", dirname)
  inc_dir = File.join(base, "inc")
  lib_dir = File.join(base, "lib", "win32")
  doc_dir = File.join(base, "docs", PRODUCT_NAME)
  exa_dir = File.join(base, "examples", PRODUCT_NAME)

  mkdir_p inc_dir
  mkdir_p lib_dir
  mkdir_p doc_dir
  mkdir_p exa_dir

  cp FileList["inc/*.bi"], inc_dir
  cp FileList["lib/win32/*.a"], lib_dir
  cp "examples/basic.bas", exa_dir
  cp "README.md", doc_dir
  cp "History.txt", doc_dir
  cp "LICENSE.txt", doc_dir

  chdir "pkg" do
    sh "zip -r #{zipfile} #{dirname}"
  end
end
