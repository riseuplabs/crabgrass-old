class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
	  t.column :node_id, :integer
	  t.column :other_node_id, :integer
    end
  end

  def self.down
    drop_table :links
  end
end
