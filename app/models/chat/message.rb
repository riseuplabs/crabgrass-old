class Message < ActiveRecord::Base

  belongs_to :channel
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  
  #validates_length_of :content, :in => 1..1000
  
  def before_create
    if sender
      self.sender_name = sender.login
    end
    true
  end
  
end
