class RemoveLocksFromWikis < ActiveRecord::Migration
  def self.up
    remove_column :wikis, :lock_version
    remove_column :wikis, :edit_locks
  end

  def self.down
    add_column :wikis, :lock_version, :integer, :default => 0
    add_column :wikis, :edit_locks, :text
  end
end
