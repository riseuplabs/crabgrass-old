# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  before_filter :login_required, :breadcrumbs

  # a default success flash
  def flash_success(msg=nil)
    flash[:notice] = msg ? msg : _("Changes saved successfully.")
  end
  
  # sets up the flash to have the current error message
  def flash_error(object_name)
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
      flash.now[:error] = _("Changes could not be saved.")
      flash.now[:text] ||= ""
      flash.now[:text] += content_tag "p", _("There are problems with the following fields") + ":"
      flash.now[:text] += content_tag "ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }
      flash.now[:errors] = object.errors
    end
  end
  
  def flash_error_msg(msg)
    flash.now[:error] = _("Changes could not be saved.")
    flash.now[:text] = content_tag "p", _("There are problems with the following fields") + ":"
    flash.now[:text] += content_tag "ul", msg
  end

  def message(opts)    
    if opts[:success]
      flash[:notice] = opts[:success]
    elsif opts[:error]
      if opts[:later]
        flash[:error] = opts[:error]
      else
        flash.now[:error] = opts[:error]
      end
    elsif opts[:object]
      object = opts[:object]
      unless object.errors.empty?
        flash.now[:error] = _("Changes could not be saved.")
        flash.now[:text] ||= ""
        flash.now[:text] += content_tag "p", _("There are problems with the following fields") + ":"
        flash.now[:text] += content_tag "ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }
        flash.now[:errors] = object.errors
      end
    end
  end
  
  def content_tag(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end
  
  # TODO: use params to determine how we got here, and generate a page path
  # using that information. ie, if we are at /group/:group_id/page/:page_id
  # then create a path that is based on group and not on user.
  def pagepath(page, options)
    url_for({:controller => 'pages', :action => 'show', :id => page}.merge(options))
  end
  
  # a before filter to override by controllers
  def breadcrumbs; end
  
  def add_crumb(crumb_text,crumb_url)
    @breadcrumbs ||= []
    @breadcrumbs << [crumb_text,crumb_url]
  end
  
  def page_url(page, options_override={})
    options = {}
    options[:controller] = page.controller || 'pages'
    options[:id] = page
    if params[:from]
      options[:from] = params[:from]
      options[:from_id] = params[:from_id]
    elsif ['groups','people','networks'].include? params[:controller]
      options[:from] = params[:controller]
      options[:from_id] = params[:id]
    elsif 'me' == params[:controller]
      options[:from] = 'people'
      options[:from_id] = current_user
    elsif page.groups.any?
      options[:from] = 'groups'
      options[:from_id] = page.groups.first.id
    elsif page.users.any?
      options[:from] = 'people'
      options[:from_id] = page.users.first.id
    end
    full_page_path_url options.merge(options_override)
  end
  
end
