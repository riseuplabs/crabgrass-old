class AddRawStructureToWikis < ActiveRecord::Migration
  def self.up
    add_column :wikis, :raw_structure, :text
    add_column :wiki_versions, :raw_structure, :text
  end

  def self.down
    remove_column :wikis, :raw_structure
    remove_column :wiki_versions, :raw_structure
  end
end
