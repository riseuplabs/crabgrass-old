# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'

require 'gettext/utils'

desc "Create mo-files for L10n"
task :makemo do
  GetText.create_mofiles(true, "po", "locale")
end
 
desc "Update pot/po files to match new version."
task :updatepo do
  MY_APP_TEXT_DOMAIN = "nest"
  MY_APP_VERSION     = "nest 0.1"
  GetText.update_pofiles(MY_APP_TEXT_DOMAIN, Dir.glob("{app,lib,components}/**/*.{rb,rhtml}"), MY_APP_VERSION)
end


desc "Reload the development environment"
task :reload => :environment do
  ActiveRecord::Base.establish_connection(:development) 
  ActiveRecord::Base.connection.execute("SET FOREIGN_KEY_CHECKS = 0")
  puts "== Dropping Tables ========================================="
  ActiveRecord::Base.connection.execute("SHOW TABLES").each do |row|
    ActiveRecord::Base.connection.execute "DROP TABLE #{row}"
    puts "#{row}"
  end
  puts "== Done ====================================================\n"
  Rake::Task["db:migrate"].invoke
  puts "== Loading Fixtures ========================================"
  Rake::Task["db:fixtures:load"].invoke
  puts "== Done ====================================================\n"
end
