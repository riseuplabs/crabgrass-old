class AddShowingsPageId < ActiveRecord::Migration
  def self.up
    add_column :showings, :page_id, :integer
  end

  def self.down
    remove_column :showings
  end
end
