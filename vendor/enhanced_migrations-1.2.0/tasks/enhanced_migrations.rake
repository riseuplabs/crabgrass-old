require 'rake'

def migration_numbers
  Dir["#{RAILS_ROOT}/db/migrate/[0-9]*_*.rb"].collect { |file| file[/(\d+)_[^\/]+\.rb$/][$1].to_i }.sort
end

def previous_migration
  raise "No migrations have been run yet" if ActiveRecord::Migrator.current_version == 0
  return "0" if migration_numbers.first == ActiveRecord::Migrator.current_version
  "#{migration_numbers.fetch(migration_numbers.index(ActiveRecord::Migrator.current_version) - 1)}" rescue nil
end

def next_migration
  raise "Already at last migration" if ActiveRecord::Migrator.current_version == migration_numbers.last
  return "#{migration_numbers.first}" if ActiveRecord::Migrator.current_version == 0
  "#{migration_numbers.fetch(migration_numbers.index(ActiveRecord::Migrator.current_version) + 1)}" rescue nil
end

namespace :enhanced_migrations do
  task :set_env do
    ENV["VERSION"] = case ENV["VERSION"]
                     when "prev", "previous"
                       previous_migration
                     when "next"
                       next_migration
                     when "first"
                       "#{migration_numbers.first}"
                     when "last"
                       "#{migration_numbers.last}"
                     when /\d+/
                       ENV["VERSION"]
                     else
                       nil
                     end
  end
end

task 'db:migrate' => 'enhanced_migrations:set_env'