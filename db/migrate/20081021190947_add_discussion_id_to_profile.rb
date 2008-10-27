class AddDiscussionIdToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :discussion_id, :integer
  end

  def self.down
    remove_column :profiles, :discussion_id
  end
end
