class RemoveGroupFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :group_id
    remove_column :pages, :group_name
    remove_column :page_terms, :group_id
    remove_column :page_terms, :group_name
    remove_index "pages", :name => "index_pages_on_name"
    add_index "pages", ["name", "owner_id"], :name => "index_pages_on_name"
  end

  def self.down
    add_column :pages, :group_id, :integer
    add_column :pages, :group_name, :string
    add_column :page_terms, :group_id, :integer
    add_column :page_terms, :group_name, :string
    remove_index "pages", :name => "index_pages_on_name"
    add_index "pages", ["name"], :name => "index_pages_on_name"
  end
end

