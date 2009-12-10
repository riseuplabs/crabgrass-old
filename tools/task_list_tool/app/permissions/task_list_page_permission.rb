module TaskListPagePermission
  def authorized?
    if @page.nil?
      true
    elsif action?(:show)
      current_user.may?(:view, @page)
    elsif action?(:create_task, :mark_task_complete, :mark_task_pending, :destroy_task, :update_task, :edit_task, :sort)
      current_user.may?(:edit, @page)
    else
      current_user.may?(:admin, @page)
    end
  end
end
