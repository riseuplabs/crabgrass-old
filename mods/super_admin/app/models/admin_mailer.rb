class AdminMailer < ActionMailer::Base
 
  def blast(user,email_options)
	setup_email(user)
	@subject += email_options[:subject]
	body :message => email_options[:body]
  end


   def notify_inappropriate(user, email_options)
	setup_email(user)
        @subject += "Inappropriate Content"
	body :message => email_options[:body], :url => email_options[:url], :owner => email_options[:owner]
   end	   

  protected

  def setup_email(user)
    @recipients   = "#{user.email}"
    @from         = current_site.email_sender
    @subject      = current_site.title + ": "
    @sent_on      = Time.now    
  end

end
