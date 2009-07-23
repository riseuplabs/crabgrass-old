class AddFlagToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :flag, :boolean
  end

  def self.down
    remove_column :activities, :flag
  end
end
