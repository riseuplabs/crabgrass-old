class CreateDailyAndHourlyTrackings < ActiveRecord::Migration
  def self.up
    create_table :hourlies do |t|
      t.integer :page_id
      t.integer :views
      t.integer :ratings
      t.integer :edits
      t.datetime :created_at
    end
    add_index :hourlies, :page_id

    create_table :dailies do |t|
      t.integer :page_id
      t.integer :views
      t.integer :ratings
      t.integer :edits
      t.date :created_at
    end
    add_index :dailies, :page_id

  end

  def self.down
    drop_table :dailies
    drop_table :hourlies
  end
end
