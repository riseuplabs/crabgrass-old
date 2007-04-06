class CreateChat < ActiveRecord::Migration
  def self.up
    create_table :channels do |t|
       t.column :name, :string
       t.column :group_id, :integer
    end
    create_table :channels_users do |t|
       t.column :channel_id, :integer
       t.column :user_id, :integer
       t.column :last_seen, :datetime
    end
    create_table :messages do |t|
      t.column :created_at, :datetime
      t.column :type, :string
      t.column :content, :text
      t.column :channel_id, :integer
      t.column :sender_id, :integer
      t.column :sender_name, :string
      t.column :level, :string
    end
    add_index :messages, :channel_id
  end 
  def self.down
    drop_table :channels
    drop_table :channels_users
    drop_table :messages
  end
end
