module Admin::AllHelper

  def tab_link(title, controller, view=nil)
    view ||= title
    link_to_active( title, :controller => controller, :action => 'index', :view => view)
  end

  def actions_for(tab)
    if tab== 'new'
      ['approve', 'trash']
    elsif tab=='vetted'
      ['trash']
    elsif tab=='deleted'
      ['undelete']
    end
  end

  def button_to_action(action, params)
    button_to(action.capitalize.t, :action => action, :params => params)
  end

  def flagged_details(foreign_id, type)
    reason = ""
    if type == 'ModeratedPage'
      flags = ModeratedPage.find_all_by_foreign_id(foreign_id)
    elsif type == 'ModeratedPost'
      flags = ModeratedPost.find_all_by_foreign_id(foreign_id)
    else
      return
    end
    flags.each do |flag|
      reason = flag.reason_flagged.empty? ? "none given" : flag.reason_flagged
    end
    return reason
  end

end
