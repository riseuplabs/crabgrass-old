class AddLastSeenAt < ActiveRecord::Migration
  def self.up
    add_column "users", "last_seen_at", :datetime
    add_index :users, :last_seen_at, :name => :index_users_on_last_seen_at
    User.reset_column_information
    User.find(:all).each do |user|
      if user.last_seen_at.nil?
        user.last_seen_at=Time.now
        user.save!
      end
    end
  end

  def self.down
    remove_index :users, :name => :index_users_on_last_seen_at
    remove_column "users", "last_seen_at"
  end
end
