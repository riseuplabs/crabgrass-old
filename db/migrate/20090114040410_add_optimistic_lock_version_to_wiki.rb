class AddOptimisticLockVersionToWiki < ActiveRecord::Migration
  def self.up
    add_column :wikis, :lock_version, :integer, :default => 0
  end

  def self.down
    remove_column :wikis, :lock_version
  end
end
