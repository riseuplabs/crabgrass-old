class WikiOptionsFromStingToText < ActiveRecord::Migration
  def self.up
    remove_column :widgets, :options
    add_column :widgets, :options, :text
  end

  def self.down
    remove_column :widgets, :options
    add_column :widgets, :options, :string
  end
end
