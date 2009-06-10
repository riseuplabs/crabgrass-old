module PersonHelper

  def friend_link
    if logged_in? and current_user.id != @user.id
      if @user.friend_of?(current_user)
        link = link_to "Remove from my contacts"[:remove_friend_link], {:controller => 'contact', :action => 'remove', :id => @user}
         content_tag :li, link, :class => 'small_icon user_delete_16'
      elsif @profile.may_request_contact?
        link = link_to "Add to my contacts"[:request_friend_link], {:controller => 'contact', :action => 'add', :id => @user}
        content_tag :li, link, :class => 'small_icon user_add_16'
      end
    end
  end

  def message_link
    if logged_in? and current_user.id != @user.id
      link = link_to "Send message"[:send_message_link], {:controller => 'message_page', :action => 'create', :id => 'message', :to => @user.name}
      content_tag :li, link, :class => 'small_icon page_message_16'
    end
  end

  def edit_profile_link
    if logged_in? and current_user.id == @user.id
      content_tag :li, link_to("Edit Profile"[:edit_profile_link], :controller => 'profile', :action => 'edit', :id => params[:profile]), :class => 'small_icon pencil_16'
    end
  end

  def choose_profile_menu
    if logged_in? and current_user.id == @user.id
      arry = []
      arry << ['Public Profile'[:public_profile],'public'] if current_site.profile_enabled?(:public)
      arry << ['Private Profile'[:private_profile],'private'] if current_site.profile_enabled?(:private)
      options = options_for_select(arry, params[:profile])
      form = form_tag('/'+@user.name, :method => 'get')
      form += select_tag('profile', options, :onchange => 'this.form.submit();')
      form += '</form>'
      content_tag :li, form, :class => 'small_icon profile_16'
    end
  end

end

