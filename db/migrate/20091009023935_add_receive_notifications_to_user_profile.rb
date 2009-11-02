class AddReceiveNotificationsToUserProfile < ActiveRecord::Migration
  def self.up
    add_column :users, :receive_notifications, :string
  end

  def self.down
    remove_column :users, :receive_notifications
  end
end
