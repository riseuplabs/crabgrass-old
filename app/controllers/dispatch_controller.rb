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
      render :file => "404.html"
    end
  end

  def find_controller
    @group = Group.find_by_name(params[:group_name])
    if params[:page_name].to_i.to_s == params[:page_name]
      @page = Page.find_by_id(params[:page_name])
    else
      @page = Page.find_by_name(params[:page_name])
    end

    raise NameError.new unless @group and @page
    
    params[:action] = 'show'
    params[:id] = @page
    params[:controller] = @page.controller
    return "Tool::#{@page.controller.camelcase}Controller" 
  end
end
