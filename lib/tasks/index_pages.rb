

require 'yaml'

# this Hash hack taken from:
# http://snippets.dzone.com/posts/show/5811
class Hash
  # Replacing the to_yaml function so it'll serialize hashes sorted (by their keys)
  # Original function is in /usr/lib/ruby/1.8/yaml/rubytypes.rb
  def to_yaml( opts = {} )
    YAML::quick_emit( object_id, opts ) do |out|
      out.map( taguri, to_yaml_style ) do |map|
        sort.each do |k, v|   # <-- here's my addition (the 'sort')
          map.add( k, v )
        end
      end
    end
  end
end

namespace :cg do

  #  For thinking_sphinx / sphinxsearch to index pages in crabgrass, we need to have
  #  a page_terms table with an entry for each page.  This rake task makes sure that
  #  each page has an up-to-date page_terms entry.

  desc "update page_terms for each page."  
  task :update_page_terms => :environment do
    val = ThinkingSphinx.deltas_enabled?
    ThinkingSphinx.deltas_enabled = false

    Page.all.each { |page| print "#{page.id} "; page.update_page_terms; STDOUT.flush; }

    ThinkingSphinx.deltas_enabled = val
    puts "done"
  end

  # The page_terms.yml file needs to be rebuild any time there is a change to tags,
  # taggings, pages, user_participations, or group_participations

  desc "updates the auto generated fixtures"
  task :update_fixtures => :environment do
    sql  = "SELECT * FROM %s"
    tables = ["page_terms"]
    ActiveRecord::Base.establish_connection
    tables.each do |table_name|
      i = "000"
      File.open("#{RAILS_ROOT}/test/fixtures/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end

  # A task for mysql tuning that cannot be done in schema.rb.
  # This should also be set in environment.rb:
  # 
  #     config.active_record.schema_format = :sql 
  # 
  # That way, the changes we make here are not lost in schema.rb,
  # instead they are captured in development_structure.sql.

  desc "optimize mysql tables for crabgrass."
  task(:optimize => :environment) do
    connection = ActiveRecord::Base.connection
    connection.execute 'ALTER TABLE page_terms ENGINE = MyISAM'
    connection.execute 'CREATE FULLTEXT INDEX idx_fulltext ON page_terms(access_ids, tags)'
  end

end

