class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.string :name
      t.integer :profile_id
      t.integer :position
      t.integer :section
      t.string :options

      t.timestamps
    end
  end

  def self.down
    drop_table :widgets
  end
end
