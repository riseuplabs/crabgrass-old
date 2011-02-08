class Admin::StatsController < Admin::BaseController

  permissions 'admin/stats'
  helper 'admin_stats'
  before_filter :get_dates
 
  def pages
    if request.post?
      pages_created_stats
      posts_created_stats
      pages_shared_stats
      @show_stats = true
    end
  end

  def people
    current_totals
    active_users
    if request.post?
      things_created 
      @show_things_created = true
    end
  end

  private

  def get_dates
    @startdate = params[:start_date]
    @enddate = params[:end_date] + ' 23:59:59' if params[:end_date]
  end

  def current_totals
    @current_users = User.find(:all).count
    @current_groups = Group.find(:all).count
    @current_committees = Committee.find(:all).count
    @current_councils = Council.find(:all).count
  end

  def active_users
    @active_users = User.active_since(1.month.ago).count
    @inactive_users = @current_users - @active_users
  end

  def things_created
    @users_created = User.created_between(@startdate, @enddate).count
    @groups_created = Group.created_between(@startdate, @enddate).count
    @committees_created = Committee.created_between(@startdate, @enddate).count
    @councils_created = Council.created_between(@startdate, @enddate).count
  end

  def pages_created_stats
    @all_pages_created = Page.created_between(@startdate, @enddate).count
    ['wiki', 'discussion', 'asset'].each do |pagetype|
      classname = pagetype.capitalize+'Page'
      instance_variable_set("@#{pagetype}_pages_created", 
        Kernel.const_get(classname).created_between(@startdate, @enddate).count)
    end
  end

  def posts_created_stats
    @all_posts_created = Post.created_between(@startdate, @enddate).count
    ['wiki', 'discussion', 'asset'].each do |pagetype|
      instance_variable_set("@#{pagetype}_posts_created", 
        Post.created_between(@startdate, @enddate).on_pagetype(pagetype.capitalize+'Page').count)
    end
  end

  def pages_shared_stats
    @all_pages_shared = PageHistory.created_between(@startdate, @enddate).count
    @pages_shared_with_users = PageHistory.created_between(@startdate, @enddate).to_user.count
    @pages_shared_with_groups = PageHistory.created_between(@startdate, @enddate).to_group('Group').count
    @pages_shared_with_committees = PageHistory.created_between(@startdate, @enddate).to_group('Committee').count
    @pages_shared_with_networks = PageHistory.created_between(@startdate, @enddate).to_group('Network').count
  end

end
