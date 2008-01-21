class StatsController < ApplicationController
  def index
    if defined?(ANALYZABLE_PRODUCTION_LOG) && File.file?(ANALYZABLE_PRODUCTION_LOG)
      render :text => '<pre>' + `pl_analyze #{ANALYZABLE_PRODUCTION_LOG}` + '</pre>'
    else
      render :text => 'no analyzable production log'
    end
  end
  
  
  def usage
    days_ago = (params[:id]||1).to_i
    stats_since( days_ago.days.ago )
    @header = "Usage in the past %s days" % days_ago
  end
  
  protected
  
  def stats_since(time)
    @pages_created = Page.count 'id', :conditions => ['created_at > ?', time]
    @page_creators = Page.count_by_sql ["SELECT count(DISTINCT created_by_id) FROM pages WHERE created_at > ?", time]
    @pages_updated = Page.count 'id', :conditions => ['updated_at > ?', time]
    @page_updaters = Page.count_by_sql ["SELECT count(DISTINCT updated_by_id) FROM pages WHERE updated_at > ?", time]
    @wikis_updated = Wiki.count 'id', :conditions => ['updated_at > ?', time]

    @users_created = User.count 'id', :conditions => ['created_at > ?', time]
    @total_users   = User.count
    @users_logged_in = User.count 'id', :conditions => ['last_seen_at > ?', time]
    
    @total_groups = Group.count
    @groups_created = Group.count 'id', :conditions => ['created_at > ?', time]
    counts_per_group = Membership.connection.select_values('SELECT count(id) FROM memberships GROUP BY group_id')
    buckets = {}
    counts_per_group.each{|i| i=i.to_i; buckets[i] ? buckets[i] += 1 : buckets[i] = 1 }
    puts buckets.inspect
    @membership_counts = buckets.sort{|a,b| b <=> a}
  end
  
end
