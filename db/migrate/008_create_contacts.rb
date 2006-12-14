class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts, :id => false do |t|
	  t.column :user_id, :integer
	  t.column :contact_id, :integer
	end
  end

  def self.down
    drop_table :contacts
  end
end
