class AddUserRelationsDiscussionId < ActiveRecord::Migration
  def self.up
    add_column :user_relations, :discussion_id, :integer
  end

  def self.down
    remove_column :user_relations, :discussion_id
  end
end
