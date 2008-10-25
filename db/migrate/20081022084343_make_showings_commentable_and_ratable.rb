class MakeShowingsCommentableAndRatable < ActiveRecord::Migration
  def self.up
    add_column :showings, :stars, :integer
    add_column :showings, :comment_id_cache, :integer
    add_column :showings, :discussion_id, :integer
  end

  def self.down
    remove_column :showings, :stars
    remove_column :showings, :comment_id_cache
    remove_column :showings, :discussion_id
  end
end
