module Admin::StatsPermission
  def may_pages_stats?
    may_admin_site?
  end
end
