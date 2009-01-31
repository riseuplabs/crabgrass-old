class CreateRsvps < ActiveRecord::Migration
  def self.up
    create_table :rsvps do |t|
      t.integer :user_id
      t.integer :event_id
      t.timestamps
    end
    add_column :events, :host_id, :integer
  end

  def self.down
    drop_table :rsvps
    remove_column :events, :host_id
  end
end
