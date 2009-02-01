class AddTimeZoneToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :time_zone, :string
  end

  def self.down
    remove_column :events, :time_zone
  end
end
