$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'rubygems'
require 'active_record'
require 'sqlite3'

ActiveRecord::Base.establish_connection({"adapter" => "sqlite3", "database" => 'test.sqlite3'})
tables = %w( mock_records counting_records foos bars )

begin
  tables.each do |table|
    ActiveRecord::Base.connection.execute("drop table #{table}");
  end
rescue
end

tables.each do |table|
  ActiveRecord::Base.connection.execute("create table #{table}(id int, name string)");
end

require 'after_commit'
