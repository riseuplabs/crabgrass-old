class AddStatusToChannelsUser < ActiveRecord::Migration
  def self.up
    add_column :channels_users, :status, :integer
  end

  def self.down
    remove_column :channels_users, :status
  end
end
