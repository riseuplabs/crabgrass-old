class StatsController < ApplicationController

  javascript :flotr

  def error
    raise 'error'
  end

  def index
    redirect_to url_for(:action => 'week')
  end

  def week
    @step = :hour
    @start = Time.now.utc - 1.week
    render :template => 'stats/stats'
  end

  def month
    @step = :quarter_day
    @start = Time.now.utc - 1.month
    render :template => 'stats/stats'
  end

  def year
    @step = :week
    @start = Time.now.utc - 1.year
    render :template => 'stats/stats'
  end

  def all_time
    @step = :month
    @start = 0
    render :template => 'stats/stats'
  end


  def version
    @version_info = grab_version_info
    respond_to do |wants|
      wants.html
      wants.xml {render :xml => @version_info}
      wants.json {render :json => @version_info}
    end
  end

#  def log
#    if defined?(ANALYZABLE_PRODUCTION_LOG) && File.file?(ANALYZABLE_PRODUCTION_LOG)
#      render :text => '<pre>' + `pl_analyze #{ANALYZABLE_PRODUCTION_LOG}` + '</pre>'
#    else
#      render :text => 'no analyzable production log'
#    end
#  end

#  def usage
#    current_stats
#    days_ago = (params[:id]||1).to_i
#    stats_since( days_ago.days.ago )
#    @header = "Usage in the past %s days" % days_ago
#  end

  protected

#  def stats_since(time)
#    @pages_created = Page.count 'id', :conditions => ['created_at > ? AND flow IS NULL', time]
#    @page_creators = Page.count_by_sql ["SELECT count(DISTINCT created_by_id) FROM pages WHERE created_at > ? AND FLOW IS NULL", time]
#    @pages_updated = Page.count 'id', :conditions => ['updated_at > ? AND flow IS NULL', time]
#    @page_updaters = Page.count_by_sql ["SELECT count(DISTINCT updated_by_id) FROM pages WHERE updated_at > ? AND FLOW IS NULL", time]
#    @wikis_updated = Wiki.count 'id', :conditions => ['updated_at > ?', time]
#    @users_created = User.on(current_site).count 'id', :conditions => ['created_at > ?', time]
#    @total_users   = User.on(current_site).count
#    @users_logged_in = User.on(current_site).count 'id', :conditions => ['last_seen_at > ?', time]
#
#    @total_groups = Group.count
#    @groups_created = Group.count 'id', :conditions => ['created_at > ?', time]
#    counts_per_group = Membership.connection.select_values('SELECT count(id) FROM memberships GROUP BY group_id')
#    buckets = {}
#    counts_per_group.each{|i| i=i.to_i; buckets[i] ? buckets[i] += 1 : buckets[i] = 1 }
#    puts buckets.inspect
#    @membership_counts = buckets.sort{|a,b| b <=> a}
#  end

  def current_stats
    @cur_users_logged_in = User.on(current_site).count 'id', :conditions => ['last_seen_at > ?', 15.minutes.ago]
    @cur_wiki_locks = Wiki.count 'id', :conditions => ["edit_locks LIKE ?", "%locked_by_id%"]
  end

  #
  # model      : [Group|Users|Page]
  # field      : [:created_at|:updated_at]
  # step       : [:day|:week|:month]
  # where      : optional WHERE clause
  #
  def time_series_data(options)
    model = options[:model]
    table = model.table_name

    start = @start
    step = @step

    field = options[:field]
    where = [
      options[:where],
      quote_sql("#{table}.#{field} > ?", start)
    ].compact.join(' AND ').insert(0, "WHERE ")
    now = Time.now.utc.to_i
    time_frame = case step
      when :hour:  1.hour.seconds
      when :quarter_day: 6.hours.seconds
      when :day:   1.day.seconds
      when :week:  1.week.seconds
      when :month: 1.month.seconds
    end
    model.connection.select_rows("
       SELECT UNIX_TIMESTAMP(#{table}.#{field}), count(*)
       FROM #{table}
       #{where}
       GROUP BY (#{now} - UNIX_TIMESTAMP(#{table}.#{field})) DIV #{time_frame}
       ORDER BY #{table}.#{field}
    ")
  end

  # takes the results of a time series data and sums up the counts
  def cumulative(data)
    result = data.inject([[0,0]]) do |sum_list, data_element|
      sum_list.push([
        data_element[0],
        sum_list.last[1] + data_element[1].to_i
      ])
    end
    result.shift
    result
  end
  helper_method :cumulative

  ##
  ## DATA SETS
  ##

  def users_created(options={})
    where = if options[:active]
      quote_sql('last_seen_at > ?', Time.now.utc - 2.week)
    end
    time_series_data(
      :model => User, :field => :created_at, :where => where
    )
  end
  helper_method :users_created

  def groups_created(options={})
    where = if options[:active]
      quote_sql('groups.id IN (SELECT memberships.group_id FROM memberships WHERE memberships.visited_at > ?)', Time.now.utc - 2.week)
    end
    time_series_data(
      :model => Group, :field => :created_at, :where => where
    )
  end
  helper_method :groups_created

  def group_size_frequency()
    membership_counts = {}  # group size => frequency
    Membership.connection.select_values('SELECT count(id) FROM memberships GROUP BY group_id').each do |membership_count|
      membership_count = membership_count.to_i
      membership_counts[membership_count] ||= 0
      membership_counts[membership_count] += 1
    end
    return membership_counts.to_a.sort{|a,b| a[0] <=> b[0] }
  end
  helper_method :group_size_frequency

  def pages_created(options={})
    where = if options[:updated]
      quote_sql('updated_at > ?', Time.now.utc - 2.week)
    end
    time_series_data(
      :model => Page, :field => :created_at, :where => where
    )
  end
  helper_method :pages_created

  def pages_updated()
    time_series_data(
      :model => Page, :field => :updated_at,
      :where => 'updated_at > (created_at + INTERVAL 1 DAY)'
    )
  end
  helper_method :pages_updated

  def grab_version_info
    ### for example:
    # version => 0.4.6
    # release => 20091016230956
    # revision => 78d9244704573366308963078182bb937c4feb91
    keys = %w(version release revision)
    version_info = {}

    keys.each do |key|
      version_info[key] = 'unknown'

      data_file = File.join(Rails.root, key.upcase)
      if File.exists?(data_file)
        data = File.read(data_file).chomp
        data = Time.parse(data).to_s(:db) if key == 'release'
        version_info[key] = data unless data.blank?
      end
    end

    version_info
  end
  private

  def quote_sql(*args)
    ActiveRecord::Base.quote_sql(args)
  end

end

