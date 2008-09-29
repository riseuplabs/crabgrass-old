module Me::BaseHelper
  
  def me_cache_key
    params.merge(:user_id => current_user.id, :version => current_user.version)
  end

  def request_state_links
    hash = {:controller => params[:controller], :action => params[:action]}
    content_tag :div, link_line(
      link_to_active(:pending.t, hash.merge(:state => 'pending')), 
      link_to_active(:approved.t, hash.merge(:state => 'approved')),
      link_to_active(:rejected.t, hash.merge(:state => 'rejected'))
    ), :style => 'margin-bottom: 1em'

  end
 
end
