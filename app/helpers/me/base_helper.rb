module Me::BaseHelper

  def request_source_links
    link_line(
      link_to_active(I18n.t(:requests_to_me), :controller => '/me/requests', :action => 'to_me', :state => params[:state]),
      link_to_active(I18n.t(:requests_from_me), :controller => '/me/requests', :action => 'from_me', :state => params[:state])
    )
  end

end
