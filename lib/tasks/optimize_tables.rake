=begin

A task for mysql tuning that cannot be done in schema.rb.

This should also be set in environment.rb:

      config.active_record.schema_format = :sql 

That way, the changes we make here are not lost in schema.rb,
instead they are captured in schema.sql.

=end

namespace :cg do
  desc "optimize mysql tables for crabgrass."
  task(:optimize => :environment) do
    connection = ActiveRecord::Base.connection
    connection.execute 'ALTER TABLE page_terms ENGINE = MyISAM'
    connection.execute 'CREATE FULLTEXT INDEX idx_access ON page_terms(access)'
  end
end

