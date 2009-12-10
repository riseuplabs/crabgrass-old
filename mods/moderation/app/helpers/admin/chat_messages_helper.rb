module Admin::ChatMessagesHelper

  def tab_link(title, view=nil)
    view ||= title
    link_to_active( title, :controller => 'admin/chat_messages', :action => 'index', :view => view)
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
    button_to(I18n.t(action.to_sym).capitalize, :action => action, :params => params)
  end

end
