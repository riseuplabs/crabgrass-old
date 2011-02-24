module Admin::StatsPermission
  def may_pages_stats?
    may_admin_site?
  end
  alias_method :may_people_stats?, :may_pages_stats?
end
