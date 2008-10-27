class CreateUserRelations < ActiveRecord::Migration
  def self.up
    create_table :user_relations do |t|
      t.integer :user_id
      t.integer :partner_id
      t.string :type
      t.boolean :is_active
      t.float :value
    end
  end

  def self.down
    drop_table :user_relations
  end
end
