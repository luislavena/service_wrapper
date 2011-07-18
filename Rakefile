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

  search_path "inc"

  # FIXME: hook mini_servie
  #lib_path    "lib/win32"

  main        "src/service_wrapper.bas"

  # FIXME: hook mini_service
  library     "mini_service"

  option defaults
end

# TODO: hook mini_service as submodule
task :build => []
task :rebuild => []
task :clobber => []

task :default => [:build]

# FIXME: Source code package
Rake::PackageTask.new(PRODUCT_NAME, PRODUCT_VERSION) do |pkg|
  pkg.need_zip = true
  pkg.package_files = FileList[]
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
