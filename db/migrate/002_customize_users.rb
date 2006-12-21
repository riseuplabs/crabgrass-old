#
# user definitions which are specific to crabgrass go here
#

class CustomizeUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :display_name, :string
    add_column :users, :time_zone, :string
    add_column :users, :language, :string, :limit => 5
    add_column :users, :avatar_id, :integer
  end

  def self.down
    remove_column :users, :display_name
    remove_column :users, :language
    remove_column :users, :time_zone
  end
end
