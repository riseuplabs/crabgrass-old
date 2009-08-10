class ChatChannel < ActiveRecord::Base
  set_table_name 'channels'

  belongs_to :group

  has_many :channels_users, :dependent => :delete_all, :class_name => 'ChatChannelsUser', :foreign_key => 'channel_id'

  has_many :users, :order => 'login asc', :through => :channels_users

  has_many :messages, :class_name => 'ChatMessage', :foreign_key => 'channel_id', :order => 'created_at asc', :dependent => :delete_all do
    def since(last_seen_id)
      find(:all, :conditions => ['id > ?', last_seen_id])
    end
  end

  def self.cleanup!
    users_just_left = ChatChannelsUser.find(:all, :conditions => ["last_seen < DATE_SUB(?, INTERVAL 1 MINUTE)", Time.now.utc.to_s(:db)])
    users_just_left.each do |ex_user|
      ChatMessage.new(:channel => ex_user.channel, :sender => ex_user.user, :content => :left_the_chatroom.t, :level => 'sys').save
      ex_user.destroy
    end
  end

  def latest_messages(time = nil)
    time ||= 1.day.ago.to_s(:db)
    messages.find(:all, :conditions => ["created_at > ?", time], :order => 'created_at DESC').reverse
  end
end
