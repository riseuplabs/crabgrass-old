class Me::InboxController < Me::BaseController
 
  def search
    if request.post?
      path = build_filter_path(params[:search])
      if path == '/'
        redirect_to url_for(:controller => '/me/inbox', :action => nil, :path => nil)
      else
        redirect_to url_for(:controller => '/me/inbox', :action => 'search', :path => nil) + path
      end
    else
      list
    end
  end

  def index
    list
  end

  def list
    params[:path] = ['descending', 'updated_at'] if params[:path].empty?
    @pages = Page.paginate_by_path(params[:path], options_for_inbox(:page => params[:page]))
    add_user_participations(@pages)
    handle_rss(
      :title => 'Crabgrass Inbox',
      :link => '/me/inbox',
      :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    ) or render(:action => 'list')
  end

  # post required
  def update
    if params[:remove] 
      remove
    else
      ## add more actions here later
    end
    if params[:path]
      redirect_to :action => 'search', :path => params[:path]
    else
      redirect_to :action => nil, :path => nil
    end
  end

  # post required
  def remove
    to_remove = params[:page_checked]
    if to_remove
      to_remove.each do |page_id, do_it|
        if do_it == 'checked' and page_id
          page = Page.find_by_id(page_id)
          if page
            upart = page.participation_for_user(@user)
            upart.inbox = false
            upart.save
          end
        end
      end
    end
  end
  
  protected
    
  # given an array of pages, find the corresponding user_participation records
  # and associate each participtions with the correct page.
  # afterwards, page.flag[:user_participation] should hold current_user's
  # participation for page.
  def add_user_participations(pages)
    pages_by_id = {}
    pages.each{|page|pages_by_id[page.id] = page}
    uparts = UserParticipation.find(:all, :conditions => ['user_id = ? AND page_id IN (?)',current_user.id,pages_by_id.keys])
    uparts.each do |part|
      pages_by_id[part.page_id].flag[:user_participation] = part
    end
  end
  
  def context
    me_context('large')
    add_context 'Inbox'[:me_inbox_link], url_for(:controller => '/me/inbox', :action => params[:action], :path => params[:path])
  end

end
