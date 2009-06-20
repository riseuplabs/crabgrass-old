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
    # if current_user.may?(:admin,@page) and upart.user_id != @page.created_by_id
    if (current_user.may?(:admin,@page) or upart.user_id == current_user.id) and upart.user_id != @page.owner_id
      link_to_remote('remove'[:remove], :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :upart_id => upart.id}, :loading => show_spinner(dom_id(upart)), :complete => hide_spinner(dom_id(upart)))
    end
  end

  # shows a link to remove a group participation (called from _permissions.html.erb)
  def link_to_remove_group_participation(gpart)
    # if current_user.may?(:admin, @page) and gpart.group_id != @page.group_id
    if (current_user.may?(:admin, @page) or (current_user.admin_for_group_ids.include?(gpart.group_id))) and gpart.group_id != @page.owner_id
      link_to_remote('remove'[:remove], :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :gpart_id => gpart.id}, :loading => show_spinner(dom_id(gpart)), :complete => hide_spinner(dom_id(gpart)))
    end
  end


end


