module WikiHelper

  def wiki_action(action, hash={})
    {:controller => 'wiki', :action => action, :group_id => @group.id,
     :profile_id => (@profile ? @profile.id : nil)}.merge(hash)
  end
  
  def wiki_edit_link(wiki_id=nil)
    # note: firefox uses layerY, ie uses offsetY
    link_to_remote_with_icon('edit wiki'.t, :icon => 'pencil', 
      :url => wiki_action('edit', :wiki_id => wiki_id),
      :with => "'height=' + (event.layerY? event.layerY : event.offsetY)" 
    )
  end

  def area_id(wiki)
    '%s_edit_area' % wiki.id
  end
  
end

