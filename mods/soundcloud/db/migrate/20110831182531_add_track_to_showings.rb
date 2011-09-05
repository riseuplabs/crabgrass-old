class AddTrackToShowings < ActiveRecord::Migration
  def self.up
    add_column :showings, :track_id, :integer
  end

  def self.down
    remove_column :showings, :track_id
  end
end
