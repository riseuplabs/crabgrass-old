
class MoreCustomizeUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :location, :string
    add_column :users, :about_me, :string
    add_column :users, :website, :string

  end

  def self.down
    remove_column :users, :location
    remove_column :users, :about_me
    remove_column :users, :website
  end
end
