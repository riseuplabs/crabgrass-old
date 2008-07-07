=begin

It would be much much more efficient to send all the emails in one blast,
using multiple recipients or bcc. However, this makes the social network
data available to anyone intercepting a single email. BCC is better, but
we might as well address each email to each person individually.

=end

class Mailer < ActionMailer::Base
  include ActionController::UrlWriter

#  def lost_password(token)
#    #set_language_if_valid(token.user.language)
#    recipients token.user.mail
#    subject += 'password reset'
#    body :token => token,
#         :url => url_for(:controller => 'account', :action => 'lost_password', :token => token.value)
#  end  

  # Send an email letting the user know that a page has been 'sent' to them.
  def page_notice(user, notice_message, options)
    setup(options)
    recipients user.email
    from "%s <%s>" % [@current_user.display_name, @site.email_sender]
    subject 'check out "%s"' % @page.title
    body({ :page => @page, :notice_message => notice_message, :from => @current_user,
     :to => user, :link => link(@page.uri) })
  end

  protected

  def link(path)
    [@protocol,@host,@port,'/',path].join
  end

  def setup(options)
    @site = options[:site]
    @user = options[:user]
    @current_user = options[:current_user]
    @page = options[:page]

    @host = default_url_options[:host] = @site.domain || options[:host]
    @port = default_url_options[:port] = options[:port]
    @protocol = default_url_options[:protocol] = options[:protocol]
    default_url_options[:only_path] = false

    #recipients options[:recipients] || (@user.email if @user)
    #from       options[:from] || @site.email_sender
    #subject    options[:subject] || ("[%s] " % @site.name)
    #body       :user  => @user
  end

end
