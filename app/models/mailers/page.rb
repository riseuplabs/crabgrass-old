module Mailers::Page

  # Send an email letting the user know that a page has been 'sent' to them.
  def share_notice(user, notice_message, options)
    setup(options)
    recipients user.email
    from "%s <%s>" % [@current_user.display_name, @site.email_sender]
    subject 'check out "%s"' % @page.title
    body({ :page => @page, :notice_message => notice_message, :from => @current_user,
     :to => user, :link => link(@page.uri) })
  end

end
