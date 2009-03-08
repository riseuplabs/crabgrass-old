class Subscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.string :notice
      t.boolean :inbox
      t.boolean :mail
      t.boolean :chat
      t.string :inbox_options
      t.string :mail_options
      t.boolean :watch
      t.string :watch_options
      t.boolean :digest
      t.string :digest_options
      t.string :encryption_required
      t.timestamps
    end
    
   # add_column :user_participations, :subscription_id, :integer
  end

  def self.down
    drop_table :subscriptions
#    remove_column :user_participations, :subscription_id
  end
end
