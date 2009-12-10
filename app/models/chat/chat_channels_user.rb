class ChatChannelsUser < ActiveRecord::Base
  set_table_name 'channels_users'

  belongs_to :chat_channel
  belongs_to :channel, :class_name => 'ChatChannel', :foreign_key => 'channel_id'
  belongs_to :user

  validates_presence_of :channel, :user

  def typing?
    return (self.status? and self.status > 0)
  end

  def join_message
    channel.messages.find(:first, :order => "id DESC", :conditions => ["sender_id = ?", user.id])
  end

  def record_user_action(action = nil)
    # tell the database that is user is still in the channel, decrement is_typing
    state = self.status ? self.status : Integer(0)

    if action == :not_typing
      if state > 0
        state -= 1
      elsif state < 0
        state += 1
      end
    elsif action == :typing
      if state < 0
        state += 1
      else
        state = 3
      end
    elsif action == :just_finished_typing
      state = -2
    end

    self.last_seen = Time.now.utc
    self.status = state
    self.save
  end

end
