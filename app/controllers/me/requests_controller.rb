#
# my requests:
#  my contact requests
#  my membership requests
#
# contact requests:
#   from other to me
#
# membership requests:
#   from other to groups i am admin of
#

class Me::RequestsController < Me::BaseController

  def index
    path = ['descending', 'created_at', 'limit', '10']
    @my_pages, @my_sections, @my_columns = my_req_list(path.dup)
    @contact_pages, @contact_sections, @contact_columns = contact_req_list(path.dup)
    @membership_pages, @membership_sections, @membership_columns = membership_req_list(path.dup)
  end

  def mine
    @pages, @columns = my_req_list(params[:path])
    render :action => 'more'
  end
  
  def contacts
    @pages, @columns = contact_req_list(params[:path])
    render :action => 'more'
  end

  def memberships
    @pages, @columns = membership_req_list(params[:path])
    render :action => 'more'
  end

  def more
    @pages, @columns = my_req_list unless @pages.any?
  end
  
  protected

  def my_req_list(path=[])
    path << 'created_by' << current_user.id
    options = options_for_me(:flow => [:contacts,:membership], :page => params[:page])
    pages = Page.find_by_path(path, options)
    columns = [:title, :created_at, :contributors_count]
    [pages, columns]
  end
  
  def contact_req_list(path=[])
    path << 'not_created_by' << current_user.id << 'type' << 'request'
    options = options_for_me(:flow => :contacts)
    pages = Page.find_by_path(path, options)
    columns = [:title, :discuss, :created_by, :created_at, :contributors_count]
    [pages, columns]
  end

  def membership_req_list(path=[])
    path << 'not_created_by' << current_user.id << 'type' << 'request'
    options = options_for_me(:flow => :membership)
    pages = Page.find_by_path(path, options)
    columns = [:title, :group, :discuss, :created_by, :created_at, :contributors_count]
    [pages, columns]
  end

  def context
    me_context('small')
    add_context 'requests', url_for(:controller => 'me/requests', :action => nil)
    add_context params[:action], url_for(:controller => 'me/requests') unless (params[:action] == 'index' || params[:action] == nil)
  end
  
end

