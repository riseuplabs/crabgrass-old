class AddAssetVersions < ActiveRecord::Migration
  def self.up
    Asset.create_versioned_table
  end

  def self.down
    Asset.drop_versioned_table
  end
end
