module GroupsHelper

  # only teachers may create groups. 
  def may_create_group?
    logged_in? and current_user.may?(:admin, current_site)
  end
end
