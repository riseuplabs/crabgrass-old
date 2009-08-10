class ChatChannel < ActiveRecord::Base
  set_table_name 'channels'

  belongs_to :group

  has_many :channels_users, :dependent => :delete_all, :class_name => 'ChatChannelsUser', :foreign_key => 'channel_id'

  has_many :users, :order => 'login asc', :through => :channels_users

  has_many :messages, :class_name => 'ChatMessage', :foreign_key => 'channel_id', :order => 'created_at asc', :dependent => :delete_all

  def latest_messages(time = nil)
    time ||= 1.day.ago.to_s(:db)
    messages.find(:all, :conditions => ["created_at > ?", time], :order => 'created_at DESC').reverse
  end

  def users_just_left
    ChatChannelsUser.find(:all, :conditions => ["last_seen < DATE_SUB(?, INTERVAL 30 SECOND) AND channel_id = ?", Time.now.utc.to_s(:db), self.id])
  end

  def active_channel_users
    @active_channel_users = ChatChannelsUser.find_by_sql(["SELECT * FROM channels_users cu WHERE cu.last_seen >= ? AND cu.channel_id = ?", 30.seconds.ago.to_s(:db), self.id])
  end
end
