class AddFieldsToPageIndex < ActiveRecord::Migration
  def self.up
    add_column :page_indices, :title, :string
    add_column :page_indices, :resolved, :boolean
    add_column :page_indices, :page_created_at, :datetime
    add_column :page_indices, :page_created_by_login, :string
    add_column :page_indices, :page_created_by_id, :integer
    add_column :page_indices, :page_updated_at, :datetime
    add_column :page_indices, :page_updated_by_login, :string
    add_column :page_indices, :group_name, :string
    add_column :page_indices, :starts_at, :datetime
  end

  def self.down
    remove_column :page_indices, :starts_at
    remove_column :page_indices, :group_name
    remove_column :page_indices, :page_updated_by_login
    remove_column :page_indices, :page_updated_at
    remove_column :page_indices, :page_created_by_id
    remove_column :page_indices, :page_created_by_login
    remove_column :page_indices, :page_created_at
    remove_column :page_indices, :resolved
    remove_column :page_indices, :title
  end
end
