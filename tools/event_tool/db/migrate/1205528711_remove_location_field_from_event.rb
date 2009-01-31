class RemoveLocationFieldFromEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :location
  end

  def self.down
    add_column :events, :location, :string
  end
end
