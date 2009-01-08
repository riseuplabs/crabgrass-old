class CreateTrackings < ActiveRecord::Migration
  def self.up
    rename_table :page_views, :trackings
    add_column :trackings, :user_id, :integer, :default => nil
    add_column :trackings, :group_id, :integer, :default => nil
    add_column :trackings, :tracked_at, :datetime
    change_column :trackings, :page_id, :integer, :null => true
    
    add_column :memberships, :visited_at, :datetime, :default => nil
    add_column :memberships, :total_visits, :int, :default => 0
    add_column :memberships, :join_method, :string
  end

  def self.down
    rename_table :trackings, :page_views
    drop_column :trackings, :user_id
    drop_column :trackings, :group_id
    change_column :page_views, :page_id, :integer, :null => false
    
    remove_column :memberships, :last_visit
    remove_column :memberships, :total_visits
    remove_column :memberships, :join_method
  end
end
