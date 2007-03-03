class CreateWikiVersions < ActiveRecord::Migration
  def self.up
    Wiki::Wiki.create_versioned_table
  end

  def self.down
    Wiki::Wiki.drop_versioned_table
  end
end
