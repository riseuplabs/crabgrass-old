
class AddNameIndexes < ActiveRecord::Migration
  def self.up
    add_index :groups, :name
    add_index :users, :login
  end

  def self.down
    remove_index :groups, :name
    remove_index :users, :login
  end
end
