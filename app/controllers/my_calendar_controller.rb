class MyCalendarController < ApplicationController
  layout 'me'
 
  def index 
    options = options_for_me( :public )
    path = '/type/event/descending/starts_at/starts/year/2007'
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
