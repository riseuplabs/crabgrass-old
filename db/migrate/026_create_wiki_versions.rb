class CreateWikiVersions < ActiveRecord::Migration
  def self.up
    Wiki.create_versioned_table
  end

  def self.down
    Wiki.drop_versioned_table
  end
end
