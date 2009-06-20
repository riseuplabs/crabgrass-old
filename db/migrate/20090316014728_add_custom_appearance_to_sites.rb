class AddCustomAppearanceToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :custom_appearance_id, :integer
  end

  def self.down
    remove_column :sites, :custom_appearance_id
  end
end
