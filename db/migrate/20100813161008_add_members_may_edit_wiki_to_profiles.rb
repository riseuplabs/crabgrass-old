class AddMembersMayEditWikiToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :members_may_edit_wiki, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :members_may_edit_wiki
  end
end
