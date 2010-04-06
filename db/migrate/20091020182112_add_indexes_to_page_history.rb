class AddIndexesToPageHistory < ActiveRecord::Migration
  def self.up
    add_index :page_histories, :user_id
    add_index :page_histories, [:object_id, :object_type]
    add_index :page_histories, :page_id
  end

  def self.down
    remove_index :page_histories, :user_id
    remove_index :page_histories, :column => [:object_id, :object_type]
    remove_index :page_histories, :page_id
  end
end
