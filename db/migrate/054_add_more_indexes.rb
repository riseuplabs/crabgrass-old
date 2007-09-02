
class AddMoreIndexes < ActiveRecord::Migration

  def self.up 
    add_index "ratings", ["rateable_type", "rateable_id"], :name => "fk_ratings_rateable"
    add_index "taggings", ["taggable_type", "taggable_id"], :name => "fk_taggings_taggable"
    add_index "tags", ["name"], :name => "tags_name"
    
    add_index "user_participations", ["viewed"], :name => "index_user_participations_viewed"
    add_index "user_participations", ["watch"], :name => "index_user_participations_watch"
    add_index "user_participations", ["star"], :name => "index_user_participations_star"
    add_index "user_participations", ["resolved"], :name => "index_user_participations_resolved"
    add_index "user_participations", ["attend"], :name => "index_user_participations_attend"
    
    add_index "pages", ["type"], :name => "index_pages_on_type"
    add_index "pages", ["flow"], :name => "index_pages_on_flow"
    add_index "pages", ["public"], :name => "index_pages_on_public"
    add_index "pages", ["resolved"], :name => "index_pages_on_resolved"
    add_index "pages", ["created_at"], :name => "index_pages_on_created_at"
    add_index "pages", ["updated_at"], :name => "index_pages_on_updated_at"
    add_index "pages", ["starts_at"], :name => "index_pages_on_starts_at"
    add_index "pages", ["ends_at"], :name => "index_pages_on_ends_at"    
      
    remove_index :groups, :name => :index_groups_avatar_id
    remove_index :groups, :name => :index_groups_admin_group_id
  end
  
  def self.down
    remove_index :ratings, :name => :fk_ratings_rateable
    remove_index :taggings, :name => :fk_taggings_taggable
    remove_index :user_participations, :name => :index_user_participations_viewed
    remove_index :user_participations, :name => :index_user_participations_watch
    remove_index :user_participations, :name => :index_user_participations_star
    remove_index :user_participations, :name => :index_user_participations_resolved
    remove_index :user_participations, :name => :index_user_participations_attend
    remove_index :pages, :name => :index_pages_on_type
    remove_index :pages, :name => :index_pages_on_flow
    remove_index :pages, :name => :index_pages_on_public
    remove_index :pages, :name => :index_pages_on_resolved
    remove_index :pages, :name => :index_pages_on_created_at
    remove_index :pages, :name => :index_pages_on_updated_at
    remove_index :pages, :name => :index_pages_on_starts_at
    remove_index :pages, :name => :index_pages_on_ends_at
    
    add_index "groups", ["avatar_id"], :name => "index_groups_avatar_id"
    add_index "groups", ["admin_group_id"], :name => "index_groups_admin_group_id"
  end

end
