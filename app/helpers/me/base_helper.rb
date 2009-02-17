module Me::BaseHelper
  
  def me_cache_key
    params.merge(:user_id => current_user.id, :version => current_user.version)
  end

  def request_state_links
    hash = {:controller => params[:controller], :action => params[:action]}
    links = []

    links << link_to_active(:pending.t, hash.merge(:state => 'pending'))
    links << link_to_active(:approved.t, hash.merge(:state => 'approved'))
    links << link_to_active(:rejected.t, hash.merge(:state => 'rejected'))

    link_line(*links)
  end
 
  def request_source_links
    link_line(
      link_to_active('to me'[:requests_to_me], :controller => '/me/requests', :action => 'to_me', :state => params[:state]),
      link_to_active('from me'[:requests_from_me], :controller => '/me/requests', :action => 'from_me', :state => params[:state])
    )
  end

end
