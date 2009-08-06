module Admin::PagesHelper

  def tab_link(title, view=nil)
    view ||= title
    link_to_active( title, :controller => 'admin/pages', :action => 'index', :view => view)
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
end
