class AlterUserAndGroupTrackingColumns < ActiveRecord::Migration
  def self.up
    change_column(:memberships, :visited_at, :timestamp)
    rename_column(:relationships, :viewed_at, :visited_at)
    change_column(:relationships, :visited_at, :timestamp)
    add_column(:relationships, :total_visits, :integer, :default => 0)
    rename_column(:trackings, :user_id, :current_user_id)
    add_column(:trackings, :user_id, :integer)
  end

  def self.down
    change_column(:memberships, :visited_at, :datetime)
    rename_column(:relationships, :visited_at, :viewed_at)
    change_column(:relationships, :viewed_at, :timestamp)
    remove_column(:relationships, :total_visits)
    remove_column(:trackings, :user_id)
    rename_column(:trackings, :current_user_id, :user_id)
  end
end
