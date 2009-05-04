class AddFaviconIdToCustomAppearances < ActiveRecord::Migration
  def self.up
    add_column :custom_appearances, :favicon_id, :integer
  end

  def self.down
    remove_column :custom_appearances, :favicon_id
  end
end
