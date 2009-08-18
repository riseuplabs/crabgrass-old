module BasePage::ParticipationHelper

  def access_sym_to_str(sym)
    if sym == :admin
      content_tag :span, "Coordinator"[:coordinator], :class=>sym
    elsif sym == :edit
      content_tag :span, "Participant"[:participant], :class=>sym
    elsif sym == :view
      "Viewer"[:viewer]
    end
  end

  # shows a link to remove a user participation (called from _permissions.html.erb)
  def link_to_remove_user_participation(upart)
    if may_remove_participation?(upart)
      link_to_remote('remove'[:remove], :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :upart_id => upart.id}, :loading => show_spinner(dom_id(upart)), :complete => hide_spinner(dom_id(upart)) + resize_modal)
    end
  end

  # shows a link to remove a group participation (called from _permissions.html.erb)
  def link_to_remove_group_participation(gpart)
    if may_remove_participation?(gpart)
      link_to_remote('remove'[:remove], :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :gpart_id => gpart.id}, :loading => show_spinner(dom_id(gpart)), :complete => hide_spinner(dom_id(gpart)) + resize_modal)
    end
  end


end


