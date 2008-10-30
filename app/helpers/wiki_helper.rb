module WikiHelper

  def wiki_action(action, hash={})
    {:controller => 'wiki', :action => action,
     :group_id => @group.id, :profile_id => @profile.id}.merge(hash)
  end
  
  def wiki_edit_link
    link_to_remote(
      'edit wiki'.t + ' &raquo; ',
      {
         :url => wiki_action('edit'),
         :loading => show_spinner('wiki-edit'),
         :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"  # firefox uses layerY, ie uses offsetY
      },
      {:style => "background: url(#{image_path('actions/pencil.png')}) no-repeat 0% 50%; padding-left: 20px;", :accesskey => 'e'}
    ) + spinner('wiki-edit')
  end

  def area_id(access)
    '%s_edit_area' % access
  end
  
end

