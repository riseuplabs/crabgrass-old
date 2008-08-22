#
# Even though database.yml and the migrations and schema.rb say utf8, this
# forced convert to unicode seems to be required to get certain languages to work
# (like multi-byte languages).
# 
# TODO: figure out what happens when you run this twice on the same database.
# 

namespace :cg do
  desc "converts mysql tables to use unicode. specifying utf8 in database.yml is not enough."
  task(:convert_to_unicode => :environment) do
    charset = 'utf8'
    collation = 'utf8_general_ci'
    execute "ALTER DATABASE #{connection.current_database} CHARACTER SET #{charset} COLLATE #{collation}"
    ActiveRecord::Base.connection.tables.each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
    end
  end
end

