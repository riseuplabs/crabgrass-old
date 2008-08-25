module BasePage::ParticipationHelper

  def select_page_access(name, blank=true)
    options = [['Coordinator'[:coordinator],'admin'],['Participant'[:participant],'edit'],['Viewer'[:viewer],'view']]
    options = [['(' + 'no change'[:no_change] + ')','']] + options if blank
    select_tag name, options_for_select(options)
  end

  def access_sym_to_str(sym)
    if sym == :admin
      content_tag :span, "Coordinator"[:coordinator], :class=>sym
    elsif sym == :edit
      content_tag :span, "Participant"[:participant], :class=>sym
    elsif sym == :view
      "Viewer"[:viewer]
    end
  end

  def link_to_remove_user_participation(upart)
    if current_user.may?(:admin,@page) and upart.user_id != @page.created_by_id
      link_to_remote('remove'[:remove], :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :upart_id => upart.id}, :loading => show_spinner(dom_id(upart)))
    end
  end

  def link_to_remove_group_participation(gpart)
    if current_user.may?(:admin, @page) and gpart.group_id != @page.group_id
      link_to_remote('remove'[:remove], :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :gpart_id => gpart.id}, :loading => show_spinner(dom_id(gpart)))
    end
  end

end

