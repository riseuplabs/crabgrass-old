module Admin::GroupsHelper

  def network_path(arg, options={})
    group_path(arg, options)
  end

  def council_path(arg, options={})
    group_path(arg, options)
  end

  def group_path(arg, options={})
    admin_group_path(arg,options)
  end

  def edit_group_path(arg)
    edit_admin_group_path(arg)
  end

  def new_group_path
    new_admin_group_path
  end

  def groups_path
    admin_groups_path
  end

  def committee_path(arg, options={})
    admin_group_path(arg,options)
  end

  def edit_committee_path(arg)
    edit_admin_group_path(arg)
  end

  def new_committee_path
    new_admin_group_path
  end

  def committees_path
    admin_group_path
  end

  def group_url(arg, options={})
    admin_group_url(arg, options)
  end
end
