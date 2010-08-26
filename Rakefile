# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

begin
  require File.dirname(__FILE__) + '/vendor/gems/thinking-sphinx-1.3.19/lib/thinking_sphinx/tasks.rb'
rescue LoadError => exc
  puts 'Warning: could not load thinking sphinx tasks';
end
