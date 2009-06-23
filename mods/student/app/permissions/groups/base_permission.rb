#
# overwriting permissions so contributions are displayed
# these help the teachers to track what their students are
# doing
#
# this is shared by all the Groups::XxxController classes
# in addition to their individual permission helpers
#

module Groups::BasePermission

  ##
  ## DISPLAY PERMISSIONS
  ##

  def may_contributions_group?(group = @group)
    true
  end

end
