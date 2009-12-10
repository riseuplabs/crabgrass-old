class AddRequireUserFullInfoToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :require_user_full_info, :boolean
  end

  def self.down
    remove_column :sites, :require_user_full_info
  end
end
