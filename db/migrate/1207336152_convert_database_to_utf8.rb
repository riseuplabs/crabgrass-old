class ConvertDatabaseToUtf8 < ActiveRecord::Migration
  def self.up
    charset = 'utf8'
    collation = 'utf8_general_ci'
    execute "ALTER DATABASE #{connection.current_database} CHARACTER SET #{charset} COLLATE #{collation}"
    connection.tables.each do |table|
      execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
    end
  end
  def self.down
    raise ActiveRecord::IrreversibleMigration.new()
  end
  def self.connection
    ActiveRecord::Base.connection
  end
end

