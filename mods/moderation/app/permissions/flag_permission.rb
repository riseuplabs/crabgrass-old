module FlagPermission

  def may_show_add_yucky?
    logged_in?
  end

  alias_method :may_add_yucky?, :may_show_add_yucky?

  def may_remove_yucky?
    @flag.user_id == current_user.id
  end

end
