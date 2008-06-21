class ChatMessage < ActiveRecord::Base

  set_table_name 'messages'

  belongs_to :channel, :class_name => 'ChatChannel', :foreign_key => 'channel_id'
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  
  #validates_length_of :content, :in => 1..1000
  
  def before_create
    if sender
      self.sender_name = sender.login
    end
    true
  end
  
end
