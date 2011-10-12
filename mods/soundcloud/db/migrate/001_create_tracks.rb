class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :title
      t.string :user
      t.string :permalink_url
      t.string :uri
      t.integer :duration

      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
