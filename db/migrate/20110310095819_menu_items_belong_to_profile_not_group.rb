class MenuItemsBelongToProfileNotGroup < ActiveRecord::Migration
  def self.up
    add_column :menu_items, :profile_id, :integer
    execute <<EOSQL
UPDATE menu_items, profiles
SET menu_items.profile_id = profiles.id
WHERE menu_items.group_id = profiles.entity_id
AND profiles.entity_type = 'Group'
AND profiles.stranger = 1
EOSQL
    remove_column :menu_items, :group_id
  end

  def self.down
    add_column :menu_items, :group_id, :integer
    execute <<EOSQL
UPDATE menu_items, profiles
SET menu_items.group_id = profiles.entity_id
WHERE menu_items.profile_id = profiles.id
EOSQL
    remove_column :menu_items, :profile_id
  end
end
