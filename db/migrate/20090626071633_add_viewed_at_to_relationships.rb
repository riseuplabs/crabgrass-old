class AddViewedAtToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :viewed_at, :datetime
    add_column :relationships, :unread_count, :integer, :default => 0
  end

  def self.down
    remove_column :relationships, :viewed_at
    remove_column :relationships, :unread_count
  end
end
