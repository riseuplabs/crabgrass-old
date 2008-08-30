
#
# opportunistic locking is auto-enabled if the column lock_version exists
# the problem is that opportunist locking gets in the way of certain features
# of acts_as_versioned (in particular, the ability to save without creating
# a new version if certain conditions are met).
#

class DisableOpportunisticLockingForWikis < ActiveRecord::Migration
  def self.up
    rename_column :wikis, :lock_version, :version
  end

  def self.down
    rename_column :wikis, :version, :lock_version
  end
end
