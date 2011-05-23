module ProfilePermission
  def may_edit_profile?(entity=@entity)
    if current_user == entity
      return true
    elsif entity.is_a?(Group)
      return true if action_name == 'show'
      return true if logged_in? and current_user.member_of?(entity)
      return false
    end
  end
  alias_method :may_edit_location_profile?, :may_edit_profile?
end
