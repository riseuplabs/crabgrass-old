class Channel < ActiveRecord::Base

  belongs_to :group
  
#  has_and_belongs_to_many :users do
  has_many :channels_users, :dependent => :delete_all
  has_many :users, :through => :channels_users do
    def push_with_attributes(user, join_attrs)
      ChannelsUser.with_scope(:create => join_attrs) { self << user }
    end
    def cleanup
      connection.execute("DELETE FROM channels_users WHERE last_seen < DATE_SUB(\'#{ Time.now.strftime("%Y-%m-%d %H:%M:%S") }\', INTERVAL 1 MINUTE) OR last_seen IS NULL")
    end
  end
  
  has_many :messages, :order => 'created_at asc', :dependent => :delete_all do
    def since(last_seen_id)
      find(:all, :conditions => ['id > ?', last_seen_id])
    end
  end
  
  def destroy_old_messages
    count = messages.count
    if count > keep
      delete_this_many = count - keep
      connection.execute "DELETE FROM messages WHERE channel_id = %s ORDER BY id ASC LIMIT %s" % [self.id, delete_this_many]
    end
  end
    
  def latest_messages(qty = nil)
    qty ||= keep
    messages.find(:all, :limit => qty, :order => 'created_at DESC').reverse
  end
  
  def users_just_left
    User.find_by_sql(["SELECT u.* FROM users u, channels_users cu WHERE cu.last_seen < DATE_SUB(?, INTERVAL 1 MINUTE) AND cu.user_id = u.id AND cu.channel_id = ?", Time.now, self.id])
  end
  
  def keep
    500
  end
  
end
