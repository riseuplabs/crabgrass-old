class AddDiscussionCommentable < ActiveRecord::Migration
  def self.up
    add_column :discussions, :commentable_id, :integer
    add_column :discussions, :commentable_type, :string
  end

  def self.down
    remove_column :discussions, :commentable_id
    remove_column :discussions, :commentable_type
  end
end
