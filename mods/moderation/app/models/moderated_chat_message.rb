class ModeratedChatMessage < ModeratedFlag 
  belongs_to :chat_message, :foreign_key => 'foreign_id'
end
