class AddActionIdToTrackings < ActiveRecord::Migration
  def self.up
    add_column :trackings, :action_id, :integer
  end

  def self.down
    remove_column :trackings, :action_id
  end
end
