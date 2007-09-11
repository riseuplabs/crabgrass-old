class MyCalendarController < ApplicationController
  layout 'me'
 
  def index(year=nil,month=nil,day=nil) 
    options = options_for_me( )
    if year.nil? and month.nil? and day.nil? then
      path = '/type/event/ascending/starts_at/starts/year/' + Time.now.year.to_s
    end
    @events = find_pages options, path
  end

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
