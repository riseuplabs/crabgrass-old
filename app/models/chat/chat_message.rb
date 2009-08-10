class ChatMessage < ActiveRecord::Base
  set_table_name 'messages'

  belongs_to :channel, :class_name => 'ChatChannel', :foreign_key => 'channel_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'

  def before_create
    if sender
      self.sender_name = sender.login
    end
    true
  end

  # returns an array of months that had messages for a particular channel
  def self.months(channel)
    sql = "SELECT MONTH(messages.created_at) AS month, YEAR(messages.created_at) AS year FROM messages "
    sql += "WHERE messages.channel_id = '#{channel.id}' "
    sql += "GROUP BY year, month ORDER BY year, month"
    ChatMessage.connection.select_all(sql)
  end

  # returns an array with the days that had messages for a given channel on a given month
  def self.days(channel, year, month)
    begin_date = Time.utc(year, month)
    end_date = begin_date.advance(:months => 1)
    sql = "SELECT DAY(messages.created_at) AS day FROM messages "
    sql += "WHERE messages.channel_id = '#{channel.id}' "
    sql += "AND messages.created_at >= '#{begin_date.to_s(:db)}' "
    sql += "AND messages.created_at < '#{end_date.to_s(:db)}' "
    sql += "GROUP BY day ORDER BY day"
    ChatMessage.connection.select_all(sql)
  end

  def self.for_day(channel, year, month, day)
    begin_date = Time.utc(year, month, day)
    end_date = begin_date.advance(:days => 1)
    conditions = "channel_id = '#{channel.id}' AND created_at >= '#{begin_date.to_s(:db)}' AND created_at < '#{end_date.to_s(:db)}'"
    ChatMessage.find(:all, :conditions => conditions, :order => "created_at ASC")
  end
end
