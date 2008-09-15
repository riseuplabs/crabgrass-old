#
# the schema for networks already exists, but now we are going to actually use it
# 
class SetupNetworks < ActiveRecord::Migration
  def self.up
    rename_table "federations", "federatings"
    add_index "federatings", ["group_id", "network_id"], :name => "gn"
    add_index "federatings", ["network_id", "group_id"], :name => "ng"
    rename_column "groups", "admin_group_id", "council_id"
    remove_column "groups", "council"
    add_column    "groups", "is_council", :boolean, :default => false
    rename_column "federatings", "delegates_id", "delegation_id"
  end

  def self.down
    rename_table "federatings", "federations"
    remove_index "federations", :name => "gn"
    remove_index "federations", :name => "ng"
    rename_column "federations", "delegation_id", "delegates_id"
    rename_column "groups", "council_id", "admin_group_id"
    remove_column "groups", "is_council"
    add_column    "groups", "council", :boolean
  end

end
