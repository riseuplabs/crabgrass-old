class AddIndexes < ActiveRecord::Migration
  def self.up
    #maybe there should be one with multiple too
    add_index "asset_versions", ["asset_id"], :name => "index_asset_versions_asset_id"
    add_index "asset_versions", ["parent_id"], :name => "index_asset_versions_parent_id"
    add_index "asset_versions", ["version"], :name => "index_asset_versions_version"
    add_index "asset_versions", ["page_id"], :name => "index_asset_versions_page_id"
    
    add_index "assets", ["parent_id"], :name => "index_assets_parent_id"
    add_index "assets", ["version"], :name => "index_assets_version"
    add_index "assets", ["page_id"], :name => "index_assets_page_id"
    
    add_index "channels", ["group_id"], :name => "index_channels_group_id"
    
    add_index "channels_users", ["channel_id", "user_id"], :name => "index_channels_users"
    
    add_index "contacts", ["contact_id", "user_id"], :name => "index_contacts"
    
    add_index "discussions", ["page_id"], :name => 'index_discussions_page_id'
    
    add_index "group_participations", ["group_id", "page_id"], :name => 'index_group_participations'
    
    add_index "groups", ["parent_id"], :name => 'index_groups_parent_id'
    add_index "groups", ['avatar_id'], :name => 'index_groups_avatar_id'
    add_index "groups", ['admin_group_id'], :name => 'index_groups_admin_group_id'
    
    add_index "links", ['page_id', 'other_page_id'], :name => 'index_links_page_and_other_page'
    
    add_index "memberships", ['group_id', 'user_id', 'page_id'], :name => 'index_memberships'
    
    add_index "messages", ['sender_id'], :name => 'index_messages_channel'
    
    add_index "page_tools", ['page_id', 'tool_id'], :name => "index_page_tools"
    
    add_index "pages", ['created_by_id'], :name => 'index_page_created_by_id'
    add_index "pages", ['updated_by_id'], :name => 'index_page_updated_by_id'
    add_index "pages", ['group_id'], :name => 'index_page_group_id'
    
    add_index "pictures", ['created_by_id'], :name => 'index_pictures_created_by_id'
    
    add_index "possibles", ['poll_id'], :name => 'index_possibles_poll_id'
    add_index "votes", ['possible_id'], :name => 'index_votes_possible'
    add_index "votes", ['possible_id', 'user_id'], :name => 'index_votes_possible_and_user'
    
    add_index "tasks", ['task_list_id'], :name => 'index_tasks_task_list_id'
    add_index "tasks", ['task_list_id','completed', 'position'], :name => 'index_tasks_completed_positions'
    add_index 'tasks_users', ['user_id', 'task_id'], :name => 'index_tasks_users_ids'
    
    add_index 'user_participations', ['page_id'], :name => 'index_user_participations_page'
    add_index 'user_participations', ['user_id'], :name => 'index_user_participations_user'
    add_index 'user_participations', ['page_id','user_id'], :name => 'index_user_participations_page_user'
    
    add_index 'wikis', ['user_id'], :name => 'index_wikis_user_id'
    add_index 'wikis', ['locked_by_id'], :name => 'index_wikis_locked_by_id'
    
    add_index 'wiki_versions', ['wiki_id'], :name => 'index_wiki_versions'
    add_index 'wiki_versions', ['wiki_id', 'updated_at'], :name => 'index_wiki_versions_with_updated_at'
        
    
  end

  def self.down
    remove_index :asset_versions, :name => :index_asset_versions_asset_id
    remove_index :asset_versions, :name => :index_asset_versions_parent_id
    remove_index :asset_versions, :name => :index_asset_versions_version
    remove_index :asset_versions, :name => :index_asset_versions_page_id
    remove_index :assets, :name => :index_assets_parent_id
    remove_index :assets, :name => :index_assets_version
    remove_index :assets, :name => :index_assets_page_id
    remove_index :channels, :name => :index_channels_group_id
    remove_index :channels_users, :name => :index_channels_users
    remove_index :contacts, :name => :index_contacts
    remove_index :discussions, :name => :index_discussions_page_id
    remove_index :group_participations, :name => :index_group_participations
    remove_index :groups, :name => :index_groups_parent_id
    remove_index :groups, :name => :index_groups_avatar_id
    remove_index :groups, :name => :index_groups_admin_group_id
    remove_index :links, :name => :index_links_page_and_other_page
    remove_index :memberships, :name => :index_memberships
    remove_index :messages, :name => :index_messages_channel
    remove_index :page_tools, :name => :index_page_tools
    remove_index :pages, :name => :index_page_created_by_id
    remove_index :pages, :name => :index_page_updated_by_id
    remove_index :pages, :name => :index_page_group_id
    remove_index :pictures, :name => :index_pictures_created_by_id
    remove_index :possibles, :name => :index_possibles_poll_id
    remove_index :votes, :name => :index_votes_possible
    remove_index :votes, :name => :index_votes_possible_and_user
    remove_index :tasks, :name => :index_tasks_task_list_id
    remove_index :tasks, :name => :index_tasks_completed_positions
    remove_index :tasks_users, :name => :index_tasks_users_ids
    remove_index :user_participations, :name => :index_user_participations_page
    remove_index :user_participations, :name => :index_user_participations_user
    remove_index :user_participations, :name => :index_user_participations_page_user
    remove_index :wikis, :name => :index_wikis_wiki_id
    remove_index :wikis, :name => :index_wikis_user_id
    remove_index :wikis, :name => :index_wikis_locked_by_id
    remove_index :wiki_versions, :name => :index_wiki_versions
    remove_index :wiki_versions, :name => :index_wiki_versions_with_updated_at
  end
end
