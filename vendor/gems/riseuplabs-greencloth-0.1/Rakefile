require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test greencloth.'
Rake::TestTask.new(:test) do |t|
  #t.libs << File.dirname(__FILE__)
  #t.libs << File.dirname(File.dirname(__FILE__))
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

