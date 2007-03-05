# controller for managing abstract pages.
# the display and editing of a particular page are handled
# by the controllers in the pages directory

class PagesController < ApplicationController
  
  def new
    if request.get?
      @page = Page.new
    elsif request.post?
      create
    end
  end
  
  def create
    groups = get_groups
    users  = get_users
    page_type = get_page_type
    return if groups.nil? or users.nil? or page_type.nil?
    
    @page = page_type.new params[:page].merge({:created_by_id => current_user.id})
    @page.new_tool
    groups.each{|g| @page.add(g) }
    users.each{|u| @page.add(u) }
    @page.tag_with(params[:tag_list])
    if @page.save
      redirect_to page_url(@page)
    else
      message :object => @page
    end
  end
 
  def tagged
    if tag_name = params[:id]
      if Tag.find_by_name(tag_name)
        @pages = Tag.find_by_name(tag_name).tagged
      end
    end
  end
   
  protected
  
  def get_groups
    return [] unless params[:group_name].any?
    group = Group.find_by_name params[:group_name]
    if group.nil?
      message :error => 'no such group'
      return nil
    end
    group = Group.find_by_id params[:group_id]
    [group]
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    begin
      klass = get_const(params['page_type'])
      return klass if klass.is_a? Page
    rescue
      return nil
    end
  end
  
end
