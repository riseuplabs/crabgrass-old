# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    return false unless logged_in?
#    if current_site and @appearance == current_site.custom_appearance and current_site.super_admin_group
#      if current_user.may?(:admin, current_site.super_admin_group)
#        return true
#      end
#    end
#
#    if current_site and @appearance == current_site.custom_appearance
#      return true if current_user.may?(:admin, current_site)
#    end
#
#    return false
#  end
module CustomAppearancesPermission
  #
  def may_update_custom_appearances?(appearance=@appearance)
    return false unless logged_in? and
      current_site and
      ( ! appearance || 
        appearance == current_site.custom_appearance )

    current_user.may?(:admin, current_site) or
    current_site.super_admin_group && current_user.may?(:admin, current_site.super_admin_group)
  end

  alias_method :may_edit_custom_appearances?, :may_update_custom_appearances?
  alias_method :may_available_custom_appearances?, :may_update_custom_appearances?
  alias_method :may_new_custom_appearances?, :may_update_custom_appearances?
end
