class Mailer < ActionMailer::Base
  include ActionController::UrlWriter

#  def lost_password(token)
#    #set_language_if_valid(token.user.language)
#    recipients token.user.mail
#    subject += 'password reset'
#    body :token => token,
#         :url => url_for(:controller => 'account', :action => 'lost_password', :token => token.value)
#  end  

  ##
  ## The @current_user@ has used the 'send page' form to send a
  ## notification message to @users@
  ## 

  def page_notice(users, notice_message, options)
    setup(options)
    recipients users.collect{|u| u.email }
    subject( subject + 'notification from %s' %s current_user.display_name )
    body :page => options[:page], :notice_message => notice_message
  end

  protected

  def setup(options)
    @site = options[:site]

    default_url_options[:host] = @site.domain || options[:host]
    default_url_options[:port] = options[:port]
    default_url_options[:protocol] = options[:protocol]
    default_url_options[:only_path] = false

    @user = options[:user] || options[:current_user]
    recipients options[:recipients] || (@user.email if @user)
    from       options[:from] || @site.email_sender
    subject    options[:subject] || ("[%s] " % @site.site_name)
    body       :user  => @user
  end

end
