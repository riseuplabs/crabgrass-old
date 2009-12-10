module ApplicationPermission

  def may_admin_site?
    # make sure we actually have a site
    logged_in? and
    !current_site.new_record? and
    current_user.may?(:admin, current_site)
  end

  def may_create_private_message?(user=@user)
    if user.nil?
      true # let someone else handle the error
    else
      current_user != user and user.profile.may_pester?
    end
  end

end
