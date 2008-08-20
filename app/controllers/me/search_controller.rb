class Me::SearchController < Me::BaseController

  def index   
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to me_url(:action => 'search') + path   
    else
      @pages, @sections = Page.find_and_paginate_by_path(params[:path], options_for_me(:method => :sphinx))
      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
        @columns = [:icon, :title, :group, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors_count]
      end
      full_url = me_url(:action => 'search') + '/' + String(parsed_path)
      handle_rss :title => full_url, :link => full_url,
                 :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    end
  end
    
  protected

  # it is impossible to see anyone else's me page,
  # so no authorization is needed.
  def authorized?
    return true
  end
  
  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('large')
    add_context 'search', url_for(:controller => 'me/search', :action => nil)
  end
    
end

