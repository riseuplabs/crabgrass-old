# 
# the idea was taken from:
# http://www.agileprogrammer.com/dotnetguy/archive/2006/07/09/16917.aspx
# 

class DispatchController < ApplicationController
  def process(request, response, method = :perform_action, *arguments)
    super(request, response, :index)
  end

  def index
    begin
      @req_host = request.env["HTTP_HOST"]
      @req_url = request.env["PATH_INFO"]
      find_controller.constantize.new.process(request, response)
    rescue NameError
      render :action => "not_found"
    end
  end

  #
  # attempt to find a page by its name, and return the correct tool controller.
  # 
  # there are possibilities:
  # 
  # - if we can find a unique page, then show that page with the correct controller.
  # - if we get a list of pages
  #   - show either a list of public pages (if not logged in)
  #   - a list of pages current_user has access to
  # - if we fail entirely, show the page not found error.
  # 

  def find_controller
    name = params[:page_name]
    @group = Group.find_by_name(params[:group_name]) if params[:group_name]
    if name.to_i.to_s == name
      # find by id, it will always be unique
      @page = Page.find_by_id(name)
    elsif @group
      # find just pages with the name that are owned by the group
      # no group should have multiple pages with the same name
      @page = @group.pages.find_by_name(name)
    else
      if logged_in?
        options = options_for_pages_viewable_by( current_user )
      else
        options = options_for_public_pages 
      end
      options[:path] = ["name",name]
      @pages = find_pages(options)
      if @pages.size == 1
        @page = @pages.first
      elsif @pages.any?
        params[:action] = 'search'
        params[:path] = ['name',name]
        params[:controller] = 'pages'
        return "PagesController"
      end
    end

    raise NameError.new unless @page
    
    params[:action] = 'show'
    params[:id] = @page
    params[:controller] = @page.controller
    return "Tool::#{@page.controller.camelcase}Controller" 
  end
end
