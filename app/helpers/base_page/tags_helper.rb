module BasePage::TagsHelper

  def remove_tag_link(tag)
    link = link_to_remote("(remove)",
      :url => {:controller => 'base_page/tags', :action => 'update', :remove => tag.name, :page_id => @page.id},
      :html => {:style => 'display:inline; padding:0;'},
      :loading  => show_spinner('tag'),
      :complete => hide("tag_#{tag.id}") + hide_spinner('tag')
    )
    content_tag(:p, h(tag.name) + ' ' + link, :id => "tag_#{tag.id}")
  end

  def options_for_edit_tag_form
    [{
      :url      => {:controller => 'base_page/tags', :action => 'update', :page_id => @page.id},
      :html     => {:id => 'edit_tag_form'},
      :loading  => show_spinner('tag')
#      :complete => hide_spinner('tag')
#      :success  => reset_form('edit_tag_form')
    }]
  end

end

