#
# we will use two kinds of locking: rails' built in optimistic locking
# and our own informal locking. 
# 
# optimistic locking makes it so that if we try to save and our model data
# is out of date (because the database was updated since when we read our data)
# rails will throw an exception. 
# 
# our own informal locking is so that if 'blue' is editing the wiki, other users
# will see that the wiki is currently being edited by someone else.
# 
# for optimistic locking in rails, we require a column named 'lock_version'
# acts_as_versioned will use this, too. so, we are going to rename our
# column 'version' to 'lock_version' and add a default (which is required)
# 
# also, reports are that this will only work if we manually specify
# lock_version like so:
#   
#   acts_as_versioned :version_column => :lock_version
# 

class AddLockingToWiki < ActiveRecord::Migration
  def self.up
    rename_column :wikis, :version, :lock_version
    execute "ALTER TABLE `wikis` ALTER COLUMN `lock_version` SET DEFAULT 0"
    add_column :wikis, :locked_at, :datetime
    add_column :wikis, :locked_by_id, :integer
  end

  def self.down
    rename_column :wikis, :lock_version, :version
    execute "ALTER TABLE `wikis` ALTER COLUMN `version` DROP DEFAULT"
    remove_column :wikis, :locked_at
    remove_column :wikis, :locked_by_id
  end
end
