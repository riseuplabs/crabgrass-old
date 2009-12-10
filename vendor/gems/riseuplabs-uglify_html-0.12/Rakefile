require "rake/testtask"

begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.title = "API Documentation for UglifyHtml"
  rd.rdoc_files.include("README.rdoc", "LICENSE", "lib/**/*.rb")
  rd.rdoc_dir = "doc"
end

begin
  require "metric_fu"
rescue LoadError
end

begin
  require "mg"
  MG.new("uglify_html.gemspec")
end

desc "Default: run tests"
task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList["test/test_*.rb"]
end
