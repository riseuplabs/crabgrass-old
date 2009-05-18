class CreateFeeds < ActiveRecord::Migration
  def self.up
    create_table :feeds do |t|
      t.integer :subscribable_id
      t.string :subscribable_type
    end
  end

  def self.down
    drop_table :feeds
  end
end

