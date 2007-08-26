#
# The idea here is that every user in a social networking universe
# has a lot of relationships to other entities that might be expensive
# to discover. For example, a list of all your peers or a list of all groups
# you have direct or indirect access to. So, we cache it.
# 
# Perhaps there is a better place to put this stuff, such as memcached.
#
# I see some advantages of keeping it in the database, particularly if
# we eventually have daemons which troll the pagespace looking for things
# you will find interesting.
#
# Also, this data will not change very often, and you will need it most of the
# time you are fetching a user anyway.
#
# The astute observer will note that this is complete insanity!
# You can't just cache all the ids for these join tables, you will quickly
# run out of bit width in your columns. 
#
# Some sketch estimation of when we will run out of space in these columns:
#
# (1) suppose an id space of 1 million, so that most ids are six digits.
# (2) using BER-compress packing, that will be 3-bytes per int, worst case.
# (3) numbers less than 16384 will pack as 2 bytes.
# (4) In rails, a string is varchar(255) which if using utf8 has
#     at most 3 x 255 or 765 bytes.
# (5) So, in 765 bytes, we can store 255 ids of the 3-byte variety
#     and 382 ids of the 2-byte variety.
#
# Therefore, I declare it unseemly for anyone to be in more than 255 groups.
#
# Yes, this would be better done with memcached. In case we are not running
# memcached, we can fall back on the database. Also, maybe this will make
# caching association ids in memcached easier to implement?
#
# As a handy bit of fun, if any of these ids caches changes, we increment the
# user's version. This can be then used to easily expire cached views which
# use these values.
#

class AddIdCachesToUser < ActiveRecord::Migration

  def self.up
    add_column :users, 'version',               :integer, :default => 0
    add_column :users, 'direct_group_id_cache', :string
    add_column :users, 'all_group_id_cache',    :string, :limit => 512
    add_column :users, 'friend_id_cache',       :string, :limit => 512
    add_column :users, 'foe_id_cache',          :string
    add_column :users, 'peer_id_cache',         :string, :limit => 1024
    add_column :users, 'tag_id_cache',          :string, :limit => 1024
  end

  def self.down
    remove_column :users, 'version'
    remove_column :users, 'direct_group_id_cache'
    remove_column :users, 'all_group_id_cache'
    remove_column :users, 'friend_id_cache'
    remove_column :users, 'foe_id_cache'
    remove_column :users, 'peer_id_cache'
    remove_column :users, 'tag_id_cache'
  end
  
end

