class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.column :possible_id, :integer
      t.column :user_id, :integer
      t.column :created_at, :datetime
      t.column :value, :integer
      t.column :comment, :string
    end
  end

  def self.down
    drop_table :votes
  end
end
