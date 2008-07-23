class AddCreatedByUpdatedByPointsToTasks < ActiveRecord::Migration
  def self.up
    change_table :tasks do |t|
      t.integer :created_by_id
      t.integer :updated_by_id
      t.integer :points
    end
  end

  def self.down
    change_table :tasks do |t|
      t.remove :created_by_id
      t.remove :updated_by_id
      t.remove :points
    end    
  end
end
