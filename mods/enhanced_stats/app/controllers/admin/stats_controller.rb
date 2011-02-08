class Admin::StatsController < Admin::BaseController

  permissions 'admin/stats'
  helper 'admin_stats'

  def index
  end

  def pages
    if request.post?
      @startdate = params[:start_date]
      @enddate = params[:end_date]
      pages_created_stats
      posts_created_stats
      pages_shared_stats
      @show_stats = true
    end
  end

  private

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
