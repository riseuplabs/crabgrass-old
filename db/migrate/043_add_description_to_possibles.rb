
class AddDescriptionToPossibles < ActiveRecord::Migration
  def self.up
    add_column :possibles, :description, :text
    add_column :possibles, :description_html, :text
  end

  def self.down
    remove_column :possibles, :description
    remove_column :possibles, :description_html
  end
end

