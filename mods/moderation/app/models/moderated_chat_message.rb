class ModeratedChatMessage < ModeratedFlag 
  belongs_to :chat_message, :foreign_key => 'foreign_id'

  def trash_chat_message
    self.chat_message.update_attribute(:deleted_at, Time.now)
  end

end
