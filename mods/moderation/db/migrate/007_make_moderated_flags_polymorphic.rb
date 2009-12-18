class MakeModeratedFlagsPolymorphic < ActiveRecord::Migration

  def self.up
    rename_column :moderated_flags, :foreign_id, :flagged_id
    add_column :moderated_flags, :flagged_type, :string
    # We use find_by_type because we can't be sure the subclasses exist
    ModeratedFlag.find_all_by_type("ModeratedPage").each do |mpage|
      # This can't be done with update all because we can't set flagged_type to the
      # specific subclasses.
      mpage.flagged=Page.find(mpage.flagged_id)
    end
    ModeratedFlag.find_all_by_type("ModeratedPost").each do |mpage|
      mpage.flagged=Post.find(mpage.flagged_id)
    end
  end

  def self.down
    rename_column :moderated_flags, :flagged_id, :foreign_id
    ModeratedFlag.update_all "type='ModeratedPage'",
      "flagged_type LIKE '%Page' OR flagged_type = 'Gallery'"
    ModeratedFlag.update_all "type='ModeratedPost'",
      "flagged_type LIKE '%Post'"
    remove_column :moderated_flags, :flagged_type
  end

end
