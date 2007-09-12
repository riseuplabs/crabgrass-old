class MyCalendarController < ApplicationController
  layout 'me'
 
  def index
    params[:participate] ||= "interesting"
    # by default all the events im watching or attending in the future
    options = options_for_me( )
    if params[:year].nil? and params[:month].nil? and params[:day].nil?
      path = '/type/event/' + params[:participate] +'/ascending/starts_at/starts/year/' + Time.now.year.to_s
    else
      path = '/type/event/' + params[:participate] + '/ascending/starts_at/starts/year/' + params[:year].to_s + '/' + params[:month].to_s + '/' +params[:day].to_s
    end
    @events = find_pages options, path
  end

  #getEventsForDay($year, $month, $day)
  #getEventsForMonth($year, $month);
  #getEventsForWeekOf($year, $month, $day); (alternately eventsForTheWeekContaing($y, $m, $d))
  #getEventsForRange($start, $end);
  #getEventsN($n, $start=today(), $end=false);

  protected
  
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
