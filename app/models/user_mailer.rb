class UserMailer < ActionMailer::Base
  def forgot_password(user)
    setup_email(user)
    @subject += _('You have requested a change of password')
    @body[:url] = "http://#{Crabgrass::Config.host}/reset_password/#{user.password_reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject += _('Your password has been reset')
  end

  protected
    def setup_email(user)
      @recipients   = "#{user.email}"
      @from         = Crabgrass::Config.email_sender
      @subject      = Crabgrass::Config.site_name + ": " 
      @sent_on      = Time.now
      @body[:user]  = user
    end
end
