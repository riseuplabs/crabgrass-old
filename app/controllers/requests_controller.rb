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

class RequestsController < ApplicationController

  before_filter :login_required
  before_filter :fetch_user
  layout 'me'

  def index
    path = ['descending', 'created_at', 'limit', '20']
    @my_pages, @my_sections, @my_columns = my_req_list(path.dup)
    @contact_pages, @contact_sections, @contact_columns = contact_req_list(path.dup)
    @membership_pages, @membership_sections, @membership_columns = membership_req_list(path.dup)
  end

  def mine
    @pages, @sections, @columns = my_req_list(params[:path])
    render :action => 'more'
  end
  
  def contacts
    @pages, @sections, @columns = contact_req_list(params[:path])
    render :action => 'more'
  end

  def memberships
    @pages, @sections, @columns = membership_req_list(params[:path])
    render :action => 'more'
  end

  def more
  end
  
  protected

  def my_req_list(path=[])
    path << 'created_by' << current_user.id
    options = options_for_pages_viewable_by(current_user, :flow => [:contacts,:membership])
    pages, page_sections = find_and_paginate_pages(options, path)
    columns = [:title, :created_at, :contributors_count]
    [pages, page_sections, columns]
  end
  
  def contact_req_list(path=[])
    path << 'not_created_by' << current_user.id << 'type' << 'request'
    options = options_for_pages_viewable_by(current_user, :flow => :contacts)
    pages, page_sections = find_and_paginate_pages(options, path)
    columns = [:title, :discuss, :created_by, :created_at, :contributors_count]
    [pages, page_sections, columns]
  end

  def membership_req_list(path=[])
    path << 'not_created_by' << current_user.id << 'type' << 'request'
    options = options_for_pages_viewable_by(current_user, :flow => :membership)
    pages, page_sections = find_and_paginate_pages(options, path)
    columns = [:title, :group, :discuss, :created_by, :created_at, :contributors_count]
    [pages, page_sections, columns]
  end

  protected
  
  def authorized?
    return true # current_user always authorized for me
  end

  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('small')
    add_context 'requests', url_for(:controller => 'requests', :action => 'index')
    add_context params[:action], url_for(:controller => 'requests') unless params[:action] == 'index'
  end
  
end

