class MoveMenuItemsFromProfilesToWidgets < ActiveRecord::Migration


  # There is a rake task to create widgets for the sites including
  # a menu bar widget that will hold the old menu_items.
  # Please run
  # rake cg:create_default_site_widgets SITE=ALL
  # before running this migration.

  def self.up
    remove_column :menu_items, :profile_id
  end

  def self.down
    add_column :menu_items, :profile_id
  end
end
