class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :feedr_accounts do |t|
      t.string :type
      t.text :credentials
      t.text :receivers
      t.boolean :active, :default => false
    end
  end
  
  def self.down
    drop_table(:feedr_accounts)
  end
end
