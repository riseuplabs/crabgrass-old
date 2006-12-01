class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :username, :string
      t.column :display_username, :string
      t.column :language, :string, :limit => 5
      t.column :crypted_password, :string, :limit => 40
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
    end
  end

  def self.down
    drop_table :users
  end
end
