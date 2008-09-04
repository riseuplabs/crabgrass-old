class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collection_pages do |t|
      t.integer :collection_id, :page_id
      t.timestamps
    end
    add_column :pages, :collection_id, :integer
  end

  def self.down
    drop_table :collection_pages
    remove_column :pages, :collection_id
  end
end
