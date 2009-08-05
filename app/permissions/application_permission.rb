module ApplicationPermission

  def may_admin_site?
    # make sure we actually have a site
    logged_in? and
    !current_site.new_record? and
    current_user.may?(:admin, current_site)
  end

  # may_admin? is used to show the Admin top menu item
  # It should be true for users who may do
  # ANY site wide admin activity:
  # * site admin
  # * super admin
  # Therefore admin mods should create
  # alias_method_chains for :may_admin?
  alias_method :may_admin?, :may_admin_site?

  def may_create_private_message?(user=@user)
    if user.nil?
      true # let someone else handle the error
    else
      current_user != user and user.profile.may_pester?
    end
  end

end
