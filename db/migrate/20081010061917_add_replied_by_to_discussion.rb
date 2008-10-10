class AddRepliedByToDiscussion < ActiveRecord::Migration
  def self.up
   rename_column :discussions, :replied_by, :replied_by_id
  end

  def self.down
   rename_column :discussions, :replied_by_id, :replied_by
  end
end
