class AddObjectToPageHistory < ActiveRecord::Migration
  def self.up
    change_table :page_histories do |t|
      t.integer :object_id
      t.string :object_type
    end
  end

  def self.down
    remove_column :object_id, :object_type
  end
end
