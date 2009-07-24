module Admin::SitesPermission
  def may_index_sites?
    current_user.may?(:admin, current_site)
  end

  alias_method :may_basic_sites?,   :may_index_sites?
  alias_method :may_profile_sites?, :may_index_sites?
  alias_method :may_signup_sites?,  :may_index_sites?
  alias_method :may_update_sites?,  :may_index_sites?
end
