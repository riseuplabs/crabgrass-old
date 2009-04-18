class Me::TrashController < Me::BaseController

  prepend_before_filter :login_with_http_auth
  
  def index
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to me_url(:action => 'trash') + path   
    else
      @pages = Page.paginate_by_path(params[:search], options_for_me(:method => :sphinx, :page => params[:page], :flow => :deleted))
      
      @columns = [:admin_checkbox, :icon, :title, :group, :deleted_by, :deleted_at, :contributors_count]
      full_url = me_url(:action => 'trash') + '/' + String(parsed_path)
      handle_rss :title => full_url, :link => full_url,
                 :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    end
  end
    
  # post required
  def update
    pages = params[:page_checked]
    if pages
      pages.each do |page_id, do_it|
        if do_it == 'checked' and page_id
          page = Page.find_by_id(page_id)
          if page
            if params[:undelete]
              page.undelete
            elsif params[:remove]
              page.destroy
              ## add more actions here later
            end
          end
        end
      end
    end
    if params[:path]
      redirect_to :action => 'index', :path => params[:path]
    else
      redirect_to :action => 'index', :path => nil
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
    add_context 'Trash'[:me_trash_link], url_for(:controller => '/me/trash', :action => nil, :path => params[:path])
  end

end

