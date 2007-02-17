class CreatePolls < ActiveRecord::Migration
  def self.up
    create_table :polls do |t|
      t.column :type, :string
    end
  end

  def self.down
    drop_table :polls
  end
end


