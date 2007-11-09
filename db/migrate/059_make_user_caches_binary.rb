class MakeUserCachesBinary < ActiveRecord::Migration
  def self.up
#    ['direct_group_id_cache', 'all_group_id_cache', 'friend_id_cache', #'foe_id_cache', 'peer_id_cache', 'tag_id_cache'].each do |column|
#      execute "ALTER TABLE `users` ALTER COLUMN `#{column}` BLOB DEFAULT NULL;"
#    end

    remove_column :users, 'direct_group_id_cache'
    remove_column :users, 'all_group_id_cache'
    remove_column :users, 'friend_id_cache'
    remove_column :users, 'foe_id_cache'
    remove_column :users, 'peer_id_cache'
    remove_column :users, 'tag_id_cache'

    add_column :users, 'direct_group_id_cache', :binary, :limit => 512
    add_column :users, 'all_group_id_cache',    :binary, :limit => 1024
    add_column :users, 'friend_id_cache',       :binary, :limit => 1024
    add_column :users, 'foe_id_cache',          :binary, :limit => 512
    add_column :users, 'peer_id_cache',         :binary, :limit => 2048
    add_column :users, 'tag_id_cache',          :binary, :limit => 2048
  end

  def self.down
    remove_column :users, 'direct_group_id_cache'
    remove_column :users, 'all_group_id_cache'
    remove_column :users, 'friend_id_cache'
    remove_column :users, 'foe_id_cache'
    remove_column :users, 'peer_id_cache'
    remove_column :users, 'tag_id_cache'

    add_column :users, 'direct_group_id_cache', :string
    add_column :users, 'all_group_id_cache',    :string, :limit => 512
    add_column :users, 'friend_id_cache',       :string, :limit => 512
    add_column :users, 'foe_id_cache',          :string
    add_column :users, 'peer_id_cache',         :string, :limit => 1024
    add_column :users, 'tag_id_cache',          :string, :limit => 1024
  end

end


