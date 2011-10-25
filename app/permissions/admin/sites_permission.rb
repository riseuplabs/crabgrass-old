module Admin::SitesPermission

  # this uses may_admin so for new records (no site config)
  # it returns false.
  def may_index_sites?
    may_admin_site?
  end

  alias_method :may_basic_sites?,   :may_index_sites?
  alias_method :may_profile_sites?, :may_index_sites?
  alias_method :may_signup_sites?,  :may_index_sites?
  alias_method :may_update_sites?,  :may_index_sites?
end
