module Admin::MembershipsHelper

  def membership_path(arg, options={})
    admin_membership_path(arg,options)
  end

  def edit_membership_path(arg)
    edit_admin_membership_path(arg)
  end

  def new_membership_path
    new_admin_membership_path
  end

  def memberships_path
    admin_memberships_path
  end

end


