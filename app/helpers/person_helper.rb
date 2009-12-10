module PersonHelper

  def friend_link
    if may_remove_contact?
      link = link_to I18n.t(:remove_friend_link), {:controller => 'contact', :action => 'remove', :id => @user}
      content_tag :li, link, :class => 'small_icon user_delete_16'
    elsif may_add_contact?
      link = link_to I18n.t(:request_friend_link), {:controller => 'contact', :action => 'add', :id => @user}
      content_tag :li, link, :class => 'small_icon user_add_16'
    end
  end

  def message_link
    if may_create_private_message?(@user)
      link = link_to I18n.t(:send_message_link), my_private_message_path(@user)
      content_tag :li, link, :class => 'small_icon page_message_16'
    end
  end

  def edit_profile_link
    if may_edit_profile?(@user)
      content_tag :li, link_to(I18n.t(:edit_profile_link), :controller => 'profile', :action => 'edit', :id => params[:profile]), :class => 'small_icon pencil_16'
    end
  end

  def choose_profile_menu
    if may_edit_profile?(@user)
      arry = []
      arry << [I18n.t(:public_profile),'public'] if current_site.profile_enabled?(:public)
      arry << [I18n.t(:private_profile),'private'] if current_site.profile_enabled?(:private)
      options = options_for_select(arry, params[:profile])
      form = form_tag('/'+@user.name, :method => 'get')
      form += select_tag('profile', options, :onchange => 'this.form.submit();')
      form += '</form>'
      content_tag :li, form, :class => 'small_icon profile_16'
    end
  end

end

