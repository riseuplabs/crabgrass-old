# controller for managing abstract pages.
# the display and editing of a particular page are handled
# by the controllers in the pages directory

class PagesController < ApplicationController
  
  def new
    return @page = Page.new if request.get?
    begin
      @page = create_new_page
      if @page.save
        redirect_to page_url(@page)
      else
        message :object => @page
      end
    rescue Exception => exc
      message :error => exc.to_s
    end
  end
  
  def create_new_page
    groups    = get_groups
    users     = get_users
    page_type = get_page_type
    
    @page = page_type.new params[:page].merge({:created_by_id => current_user.id})
    groups.each{|g| @page.add(g) } if groups
    users.each {|u| @page.add(u) }
    @page.tag_with(params[:tag_list])
    @page
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
    if params[:group_name].any?
      group = Group.find_by_name params[:group_name]
      raise Exception.new('no such group %s' % params[:group_name]) if group.nil?
      [group]
    elsif params[:group_id].any?
      group = Group.find_by_id params[:group_id]
      raise Exception.new('no such group') if group.nil?
      [group]
    end
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    raise Exception.new('page type required') unless params['page_type']
    return get_tool_class(params['page_type'])
    # Module.const_get(params['page_type'])
    # ^^^ why does't this work?! something to do with rails weird lazy loading?
    # instead, we have the silliest looking case statement on earth:
#    pt = case params['page_type']
#      when 'Tool::Wiki';       Tool::Wiki
#      when 'Tool::Discussion'; Tool::Discussion
#      when 'Tool::Event';      Tool::Event
#      when 'Tool::RateMany';   Tool::RateMany
#    end
#    raise Exception.new('page type is not a subclass of page') unless pt.superclass == Page
#    return pt
  end
  
end
