class AddEditLocksToWikis < ActiveRecord::Migration
  def self.up
    add_column :wikis, :edit_locks, :text
    
    # get rid of the old locks attributes
    remove_column :wikis, :locked_at
    remove_column :wikis, :locked_by_id
  end
  

  def self.down
    add_column :wikis, :locked_at, :datetime
    add_column :wikis, :locked_by_id, :integer, :limit => 11
    
    remove_column :wikis, :edit_locks
  end
end
