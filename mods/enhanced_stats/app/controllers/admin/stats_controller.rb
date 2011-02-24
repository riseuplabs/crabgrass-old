class Admin::StatsController < Admin::BaseController

  permissions 'admin/stats'
  helper 'admin_stats'
  before_filter :get_dates
 
  def pages
    if request.post?
      pages_created_stats
      pages_edited_stats
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
    @enddate = params[:end_date]
  end

  def current_totals
    @current_live_stats = []
    @current_users = User.find(:all).count
    @current_live_stats << ['Users', @current_users]
    ['Group', 'Committee', 'Council'].each do |thing|
      @current_live_stats << ["#{thing}s",
      Kernel.const_get(thing).find(:all).count]
    end
  end

  def active_users
    @active_users = User.active_since(1.month.ago).count
    @inactive_users = @current_users - @active_users
  end

  def things_created
    @things_created = []
    ['User', 'Group', 'Committee', 'Council'].each do |thing|
      @things_created << ["#{thing}s",
      Kernel.const_get(thing).created_between(@startdate, @enddate).count]
    end
  end

  def pages_created_stats
    @pages_created_totals = [] 
    total = 0
    current_site.available_page_types.each do |pagetype|
      next if Page.class_name_to_class(pagetype).nil? or Page.class_name_to_class(pagetype).internal
      count = Kernel.const_get(pagetype).created_between(@startdate, @enddate).count
      @pages_created_totals << [pagetype_to_plural_string(pagetype),count]
      total += count
    end
    @pages_created_totals.unshift(['All Page Types', total])
  end

  def posts_created_stats
    @posts_created_totals = []
    total = 0
    current_site.available_page_types.each do |pagetype|
      next if Page.class_name_to_class(pagetype).nil? or Page.class_name_to_class(pagetype).internal
      count = Post.created_between(@startdate, @enddate).on_pagetype(pagetype).count
      @posts_created_totals << [pagetype_to_plural_string(pagetype),count]
      total += count
    end
    @posts_created_totals.unshift(['All Page Types', total])
  end

  def pages_shared_stats
    @pages_shared_totals = []
    total = 0
    with_i = PageHistory.grant_accesses.created_between(@startdate, @enddate).to_user.count
    @pages_shared_totals << ['With Individuals', with_i]
    total += with_i
    ['Group', 'Committee', 'Council', 'Network'].each do |grouptype|
      count = PageHistory.grant_accesses.created_between(@startdate, @enddate).to_group(grouptype).count
      @pages_shared_totals << ["With #{grouptype}s", count]
      total += count
    end
    @pages_shared_totals.unshift(['Total', total])
  end

  def pages_edited_stats
    @pages_edited_totals = []
    total = 0
    current_site.available_page_types.each do |pagetype|
      next if Page.class_name_to_class(pagetype).nil? or Page.class_name_to_class(pagetype).internal
      count = PageHistory.page_updates.only_pagetype(pagetype).created_between(@startdate, @enddate).size
      @pages_edited_totals << [pagetype_to_plural_string(pagetype),count]
      total += count
    end
    @pages_edited_totals.unshift(['All Page Types', total])
  end
 
  def pagetype_to_plural_string(pagetype)
    # in order to show the translated page type display names in plural, we need a method for that in lib/page_class_proxy.rb    # because the translation is done in that lib so by now it's too late to pluralize
    #Kernel.const_get(pagetype).class_display_name, 
    name = Page.class_name_to_class(pagetype).short_class_name 
    name + ' Pages'
  end

end
