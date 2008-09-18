=begin

Multiple recipients
-------------------

It would be much much more efficient to send all the emails in one blast,
using multiple recipients or bcc. However, this makes the social network
data available to anyone intercepting a single email. BCC is better, but
we might as well address each email to each person individually.

Mailer options
--------------

There are various tricks you can use to get around the fact that mailers
are models and don't have access to the request or the session. 

In our case, we can't use the: the mailer needs to know that request and
sessiond data, because there might be multiple sites, each with their own
domain, running on the same instances of rails. 

So, we have ApplicationController#mailer_options(). This bundles up everything
from the session that is needed for the mailer to get the domain and the
protocol right. 

Every call to deliver should include as its last argument the mailer_options.
For example:
   
   Mailer::Page.deliver_page_notice(user, message, mailer_options)

Then, every mailer method should do this as its first line:

   setup(options)


=end

class Mailer < ActionMailer::Base
  include ActionController::UrlWriter
  include Mailers::Page
  include Mailers::User
  include Mailers::Request

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
  end

end
