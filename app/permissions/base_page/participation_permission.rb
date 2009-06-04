module BasePage::ParticipationPermission
#  def authorized?
#    if action?('update_public','create','destroy', 'move','set_owner')
#      current_user.may? :admin, @page
#    else
#      current_user.may? :view, @page
#    end
#  end
  def may_create_participation?(page=@page)
    page and current_user.may? :admin, page
  end

  %w(update_public destroy move set_owner).each{ |action|
    alias_method "may_#{action}_participation?".to_sym, :may_create_participation?
  }

  def may_read_participation?(page=@page)
    page and current_user.may? :view, page
  end

  %w(add_star remove_star add_watch remove_watch show_popup close_details).each{ |action|
    alias_method "may_#{action}_participation?".to_sym, :may_read_participation?
  }
end
