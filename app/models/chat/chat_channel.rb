class ChatChannel < ActiveRecord::Base

  set_table_name 'channels'

  belongs_to :group  
  has_many :channels_users, :dependent => :delete_all, :class_name => 'ChatChannelsUser', :foreign_key => 'channel_id'

  has_many :users, :order => 'login asc', :through => :channels_users do
    def push_with_attributes(user, join_attrs)
      ChatChannelsUser.create join_attrs.merge(:user => user, :channel => proxy_owner)
    end
#    def cleanup
#      connection.execute("DELETE FROM channels_users WHERE last_seen < DATE_SUB(\'#{ Time.zone.now.strftime("%Y-%m-%d %H:%M:%S") }\', INTERVAL 1 MINUTE) OR last_seen IS NULL")
#    end
  end
  
  has_many :messages, :class_name => 'ChatMessage', :foreign_key => 'channel_id', :order => 'created_at asc', :dependent => :delete_all do
    def since(last_seen_id)
      find(:all, :conditions => ['id > ?', last_seen_id])
    end
  end
  
  def latest_messages(time = nil)
    time ||= 1.day.ago.to_s(:db)
    messages.find(:all, :conditions => ["created_at < ?", time], :order => 'created_at DESC').reverse
  end
  
  def users_just_left
    ChatChannelsUser.find(:all, :conditions => ["last_seen < DATE_SUB(?, INTERVAL 30 SECOND) AND channel_id = ?", Time.zone.now.to_s(:db), self.id])
  end
  
  def active_channel_users
    @active_channel_users = ChatChannelsUser.find_by_sql(["SELECT * FROM channels_users cu WHERE cu.last_seen >= ? AND cu.channel_id = ?", 30.seconds.ago.to_s(:db), self.id])
  end
  
  def keep
    500
  end

  def record_seeing_user(user, typing_action)
    # use typing_delta to change typing counter, but keep value bounded between -2 and 2
    typing = 0
    c_user = self.channels_users.find_by_user_id(user.id)
    if c_user and c_user.typing?
      typing = c_user.typing
      if typing_action == 2 and typing < 2
        typing += 2
      elsif typing_action == -2
        typing = -2
      elsif typing_action == 0 and typing > 0
        typing -= 1
      end
    end
    
    self.users.delete(user)
    self.users.push_with_attributes(user, { :last_seen => Time.zone.now, :typing => 10 })
  end
end
