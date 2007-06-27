#

class CustomizeGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :language, :string, :limit => 5
    add_column :groups, :website, :string
    add_column :groups, :location, :string
    add_column :groups, :year_founded, :integer

 
  end

  def self.down
    remove_column :groups, :language
    remove_column :groups, :website
    remove_column :groups, :location
    remove_column :groups, :year_founded
  end
end
