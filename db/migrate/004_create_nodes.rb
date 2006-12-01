class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.column :name, :string
      t.column :node_type, :string
	  t.column :created_at, :timestamp
	  t.column :updated_at, :timestamp

	  t.column :public, :boolean

      t.column :created_by_id, :integer
	  t.column :updated_by_id, :integer
	  
	  # polymorphic association
	  t.column :tool_id, :integer
	  t.column :tool_type, :string
    end
  end

  def self.down
    drop_table :nodes
  end
end
