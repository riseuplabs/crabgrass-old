class CreatePageTools < ActiveRecord::Migration
  def self.up
    create_table :page_tools do |t|
      t.column :page_id, :integer	  
	  # polymorphic association
	  t.column :tool_id, :integer
	  t.column :tool_type, :string
    end
  end

  def self.down
    drop_table :page_tools
  end
end
