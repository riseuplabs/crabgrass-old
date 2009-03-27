class AddSiteIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :site_id, :integer
  end

  def self.down
    remove_column :groups, :site_id
  end
end
