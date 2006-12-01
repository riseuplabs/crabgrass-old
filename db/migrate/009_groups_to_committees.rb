class GroupsToCommittees < ActiveRecord::Migration
  def self.up
    create_table :groups_to_committees do |t|
	  t.column :group_id, :integer
	  t.column :committee_id, :integer
	end
  end

  def self.down
    drop_table :groups_to_committees
  end
end
