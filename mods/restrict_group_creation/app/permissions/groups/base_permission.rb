#
# overwriting permissions so groups and networks can only 
# be created by site admins
#
# this is shared by all the Groups::XxxController classes
# in addition to their individual permission helpers
#

module Groups::BasePermission

  ##
  ## BASIC GROUP CRUD
  ##

  def may_create_group?(parent = nil)
    return false unless logged_in?
    parent.nil? ?
      may_admin_site :
      may_admin_group?(parent)
  end
  alias_method :may_new_group?, :may_create_group?
  alias_method :may_create_network?, :may_create_group?

  ##
  ## ORGANIZATIONAL PERMISSIONS
  ##
  
  # subcomittees may still be created by everyone. We also 
  # use this for exceptions to the may_create_group? rule.
  def may_create_subcommittees?(group = @group)
    current_user.may?(:admin, group) and group.parent_id.nil?
  end

end

