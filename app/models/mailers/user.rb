module Mailers::User

  def forgot_password(token, options)
    setup(options)
    setup_email(token.user)
    @subject += 'You have requested a change of password'[:requested_forgot_password]
    @body[:url] = url_for(:controller => 'account', :action => 'reset_password', :token => token.value)
  end

  def reset_password(user, options)
    setup(options)
    setup_email(user)
    @subject += 'Your password has been reset'[:password_was_reset]
  end

  protected

  def setup_email(user)
    @recipients   = "#{user.email}"
    @from         = @site.email_sender
    @subject      = @site.name + ": "
    @sent_on      = Time.now
    @body[:user]  = user
  end

end
