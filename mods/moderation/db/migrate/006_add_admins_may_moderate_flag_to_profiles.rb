class AddAdminsMayModerateFlagToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :admins_may_moderate, :boolean
  end

  def self.down
    remove_column :profiles, :admins_may_moderate
  end
end
