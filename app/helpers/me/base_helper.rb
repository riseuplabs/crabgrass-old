module Me::BaseHelper

  def request_source_links
    link_line(
      link_to_active(I18n.t(:requests_to_me), :controller => '/me/requests', :action => 'to_me', :state => params[:state]),
      link_to_active(I18n.t(:requests_from_me), :controller => '/me/requests', :action => 'from_me', :state => params[:state])
    )
  end

  def say_box_onblur
    onblur = remote_function(
      :url => {:controller => '/me/messages', :action => 'public'},
      :with => "'post[body]='+value",
      :loading => show_spinner('say'),
      :complete => hide_spinner('say')
    )
  end

end
