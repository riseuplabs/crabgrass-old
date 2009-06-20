class AddAdminsToCustomAppearances < ActiveRecord::Migration
  def self.up
    add_column :custom_appearances, :admin_group_id, :integer
  end

  def self.down
    remove_column :custom_appearances, :admin_group_id
  end
end
