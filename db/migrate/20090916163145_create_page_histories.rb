class CreatePageHistories < ActiveRecord::Migration
  def self.up
    create_table :page_histories do |t|
      t.integer :user_id
      t.integer :page_id
      t.string  :type
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :page_histories
  end
end
