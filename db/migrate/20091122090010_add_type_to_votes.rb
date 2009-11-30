class AddTypeToVotes < ActiveRecord::Migration
  def self.up
    add_column :votes, :type, :string
  end

  def self.down
    remove_column :votes, :type
  end
end
