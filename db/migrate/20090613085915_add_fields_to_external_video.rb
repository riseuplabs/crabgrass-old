class AddFieldsToExternalVideo < ActiveRecord::Migration
  def self.up
    add_column :external_videos, :height, :integer, :limit => 3
    add_column :external_videos, :width, :integer, :limit => 3
    add_column :external_videos, :player, :integer, :limit => 1
  end

  def self.down
    remove_column :external_videos, :height
    remove_column :external_videos, :width
    remove_column :external_videos, :player
  end
end
