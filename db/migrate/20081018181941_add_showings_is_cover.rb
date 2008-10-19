class AddShowingsIsCover < ActiveRecord::Migration
  def self.up
    add_column :showings, :is_cover, :boolean, :default => false
  end

  def self.down
    remove_column :showings, :is_cover
  end
end
