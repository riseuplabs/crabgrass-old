
class SpellGroupPrivacyFlagsCorrectly < ActiveRecord::Migration
  def self.up
    remove_column :groups, :publicly_visable_group
    remove_column :groups, :publicly_visable_committees
    remove_column :groups, :publicly_visable_members

    add_column :groups, :publicly_visible_group, :boolean
    add_column :groups, :publicly_visible_committees, :boolean
    add_column :groups, :publicly_visible_members, :boolean
  end

  def self.down
    remove_column :groups, :publicly_visable_group
    remove_column :groups, :publicly_visable_committees
    remove_column :groups, :publicly_visable_members

    add_column :groups, :publicly_visable_group, :boolean
    add_column :groups, :publicly_visable_committees, :boolean
    add_column :groups, :publicly_visable_members, :boolean
  end
end

