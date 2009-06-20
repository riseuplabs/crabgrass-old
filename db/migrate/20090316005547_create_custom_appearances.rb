class CreateCustomAppearances < ActiveRecord::Migration
  def self.up
    create_table :custom_appearances do |t|
      t.text    :parameters
      t.integer :parent_id

      t.timestamps
    end
  end

  def self.down
    drop_table :custom_appearances
  end
end
