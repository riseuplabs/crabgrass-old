class Admin::StatsController < Admin::BaseController

  permissions 'admin/stats'
  helper 'admin_stats'

  def index
  end

  def pages
    if request.post?
      st = params[:start_date]
      ed = params[:end_date]
      pages_created_stats(st, ed)
      posts_created_stats(st, ed)
      pages_shared_stats(st, ed)
      @show_stats = true
    end
  end

  private

  def pages_created_stats(st, ed)
    @all_pages_created = Page.created_between(st, ed).count
    ['wiki', 'discussion', 'asset'].each do |pagetype|
      classname = pagetype.capitalize+'Page'
      instance_variable_set("@#{pagetype}_pages_created", Kernel.const_get(classname).created_between(st, ed).count)
    end
  end

  def posts_created_stats(st, ed)
    @all_posts_created = Post.created_between(st, ed).count
    ['wiki', 'discussion', 'asset'].each do |pagetype|
      instance_variable_set("@#{pagetype}_posts_created", 
        Post.created_between(st, ed).on_pagetype(pagetype.capitalize+'Page').count)
    end
  end

  def pages_shared_stats(st, ed)
    @all_pages_shared = PageHistory.created_between(st, ed).count
    @pages_shared_with_users = PageHistory.created_between(st, ed).to_user.count
    @pages_shared_with_groups = PageHistory.created_between(st, ed).to_group('Group').count
    @pages_shared_with_committees = PageHistory.created_between(st, ed).to_group('Committee').count
    @pages_shared_with_networks = PageHistory.created_between(st, ed).to_group('Network').count
  end

end
