module Mailers::User

  def forgot_password(token, options)
    setup(options)
    setup_email(token.user)
    @subject += I18n.t(:requested_forgot_password)
    @body[:url] = url_for(:controller => 'account', :action => 'reset_password', :token => token.value)
  end

  def reset_password(user, options)
    setup(options)
    setup_email(user)
    @subject += I18n.t(:password_was_reset)
  end

  protected

  def setup_email(user)
    @recipients   = "#{user.email}"
    @from         = "%s <%s>" % [I18n.t(:reset_password), @from_address]
    @subject      = @site.title + ": "
    @sent_on      = Time.now
    @body[:user]  = user
  end

end
