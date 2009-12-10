class ChangedWikiEditLocksType < ActiveRecord::Migration
  def self.up
    # changed the wiki edit_locks serialized field type 
    # from HashWithIndifferentAccess to Hash
    # so we have to wipe out the old locks.
    Wiki.update_all 'edit_locks = NULL'
  end

  def self.down
    Wiki.update_all 'edit_locks = NULL'
  end
end
