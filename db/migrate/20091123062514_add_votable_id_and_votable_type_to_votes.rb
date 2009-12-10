class AddVotableIdAndVotableTypeToVotes < ActiveRecord::Migration
  def self.up
    add_column :votes, :votable_id, :integer
    add_column :votes, :votable_type, :string
  end

  def self.down
    remove_column :votes, :votable_id
    remove_column :votes, :votable_type
  end
end
