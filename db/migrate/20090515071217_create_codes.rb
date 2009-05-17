class CreateCodes < ActiveRecord::Migration
  def self.up
    create_table :codes do |t|
      t.string :code, :limit => 10
      t.integer :page_id
      t.integer :user_id
      t.integer :access
      t.datetime :expires_at
      t.string :email

      #t.string :type
      #t.boolean :multi
      #t.integer :group_id
      #t.integer :creator_id
      t.timestamps
    end
    add_index :codes, :code, :unique => true
    add_index :codes, :expires_at
  end

  def self.down
    drop_table :codes
  end
end

