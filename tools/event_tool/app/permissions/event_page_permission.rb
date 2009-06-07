module EventPagePermission
  def authorized?
    if params[:action] == 'set_event_description' or params[:action] == 'edit'
      return current_user.may?(:admin, @page)
    else
      return true
    end
  end
end
