class AddVideoIdToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :video_id, :integer
  end

  def self.down
    remove_column :profiles, :video_id
  end
end
