module ProfilePermission 
  #  def authorized?
  #    if @entity.is_a?(User) and current_user == @entity
  #      return true
  #    elsif @entity.is_a?(Group)
  #      return true if action_name == 'show'
  #      return true if logged_in? and current_user.member_of?(@entity)
  #      return false
  #    elsif action_name =~ /add_/
  #     return true # TODO: this is the right way to do this
  #    end
  #  end
  #  TODO: this does not feel right at all. Just tried to translate
  #  what was in the authorized? before but it does not seem to make
  #  sense to me...
  def may_update_profile?(entity=@entity)
    return false unless logged_in?
    entity.is_a?(User) && current_user == entity or
    entity.is_a?(Group) && current_user.member_of?(entity)
  end

  alias_method :may_edit_profile?, :may_update_profile?

  def may_show_profile?(entity=@entity)
    entity.is_a?(Group) or
    entity.is_a?(User) && current_user == entity
  end

end
