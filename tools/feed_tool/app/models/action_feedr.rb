class ActionFeedr < ActionMailer::Base
  
  def self.controller_path *args
    "#{RAILS_ROOT}/app/controllers/application.rb"
  end
  
  def digest_message *messages
    user = messages[0].user
    recipients [user.email]
    from !!SENDER_ADDRESS!!
    subject !!SUBJECT!!
    date Time.now
    body :messages => messages
  end
end
