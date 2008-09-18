class CreateCollections < ActiveRecord::Migration
  def self.up
    rename_column :links, :page_id, :from
    rename_column :links, :other_page_id, :to
  end

  def self.down
  end
end
