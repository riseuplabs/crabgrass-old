class AddPositionToPossibles < ActiveRecord::Migration
  def self.up
  	add_column :possibles, :position, :integer
  end

  def self.down
  	remove_column :possibles, :position
  end
end
