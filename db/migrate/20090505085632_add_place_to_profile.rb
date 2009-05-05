class AddPlaceToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :place, :string
  end

  def self.down
    remove_column :profiles, :place
  end
end
