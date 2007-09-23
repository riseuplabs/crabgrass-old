class MyCalendarController < ApplicationController
  layout 'me'
 
  def index
    params[:participate] ||= "interesting"
    # by default all the events im watching or attending in the future
    options = options_for_me()
    path = '/type/event/' + params[:participate] + '/ascending/starts_at/starts/after/now' 
    @events = find_pages options, path
  end

  def day
    params[:participate] ||= "interesting"
    # by default all the events im watching or attending in the future
    options = options_for_me()
    path = '/type/event/' + params[:participate] +'/ascending/starts_at/starts/after/today/before/today'
    @events = find_pages options, path
    render :action => 'index'
  end

  def week
   last_sunday = Time.now - Time.now.wday.days
   next_sunday = last_sunday + 7.days
   options = options_for_me()
   path = event_path + "after/#{last_sunday.to_date}/before/#{next_sunday.to_date}"
   @events = find_pages options, path
    render :action => 'index'
  end

  def month
    # by default all the events this month
    # params[:month] not null shows all the events in the month month
    if params[:month].nil?
      first_day_month = Time.now - Time.now.mday.days
      last_day_month = Time.now.next_month - Time.now.next_month.mday.days
      options = options_for_me()
      path = event_path + "after/#{first_day_month.to_date}/before/#{last_day_month.to_date}"
    end
    @events = find_pages options, path
    render :action => 'index'
  end

  protected
  
  def event_path
    "/type/event/#{params[:participate]||'interesting'}/ascending/starts_at/starts/"
  end
   
  append_before_filter :fetch_user
  def fetch_user
    @user = current_user
  end
  
  # always have access to self
  def authorized?
    return true
  end
  
  def context
    me_context('large')
    add_context 'inbox'.t, url_for(:controller => 'inbox', :action => 'index')
  end
  
  
end
