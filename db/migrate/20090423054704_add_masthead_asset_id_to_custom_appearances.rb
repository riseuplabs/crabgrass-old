class AddMastheadAssetIdToCustomAppearances < ActiveRecord::Migration
  def self.up
    add_column :custom_appearances, :masthead_asset_id, :integer
  end

  def self.down
    remove_column :custom_appearances
  end
end
