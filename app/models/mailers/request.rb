module Mailers::Request

  # Send an email letting the user know that a page has been 'sent' to them.
  def request_to_join_us(request, options)
    setup(options)
    accept_link = url_for(:controller => 'requests', :action => 'accept',
       :path => [request.code, request.email.gsub('@','_at_')])
    group_home = url_for(:controller => request.group.name) # tricky way to get url /groupname

    recipients request.email
    subject I18n.t(:group_invite_subject, :group => request.group.display_name)
    body({ :from => @current_user, :group => request.group, :link => accept_link,
       :group_home => group_home })
  end

end

