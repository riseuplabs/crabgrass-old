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
end
