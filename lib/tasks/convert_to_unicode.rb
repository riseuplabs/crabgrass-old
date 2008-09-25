#
# Even though database.yml and the migrations and schema.rb say utf8, this
# forced convert to unicode seems to be required to get certain languages to work
# (like multi-byte languages).
# 
# This task should only need to be run once. However, running it again won't hurt.
# 

namespace :cg do
  desc "converts mysql tables to use unicode. specifying utf8 in database.yml is not enough."
  task(:convert_to_unicode => :environment) do
    charset = 'utf8'
    collation = 'utf8_general_ci'
    @connection = ActiveRecord::Base.connection
    @connection.execute "ALTER DATABASE #{@connection.current_database} CHARACTER SET #{charset} COLLATE #{collation}"
    @connection.tables.each do |table|
      @connection.execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
    end
  end
end


