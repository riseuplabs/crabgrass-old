class GroupsToSubgroups < ActiveRecord::Migration
  def self.up
    create_table :groups_to_subgroups do |t|
	  t.column :group_id, :integer
	  t.column :subgroup_id, :integer
	end
  end

  def self.down
    drop_table :groups_to_subgroups
  end
end
