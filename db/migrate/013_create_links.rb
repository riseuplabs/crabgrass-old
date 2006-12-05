class CreateLinks < ActiveRecord::Migration
  def self.up
    create_table :links, :id => false do |t|
	  t.column :page_id, :integer
	  t.column :other_page_id, :integer
    end
  end

  def self.down
    drop_table :links
  end
end
