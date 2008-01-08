module WikiHelper

  def wiki_action(action, hash={})
    {:controller => 'wiki', :action => action,
     :group_id => @group.id, :profile_id => @profile.id}.merge(hash)
  end
  
  def area_id(access)
    '%s_edit_area' % access
  end
  
end

