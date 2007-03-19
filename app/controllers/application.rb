# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageUrlHelper
  
  before_filter :login_required, :fetch_page, :breadcrumbs

  # rails lazy loading does work well with namespaced classes, so we help it along: 
  def get_tool_class(tool_class_str)
    klass = Module
    tool_class_str.split('::').each do |const|
       klass = klass.const_get(const)
    end
    unless klass.superclass == Page
      raise Exception.new('page type is not a subclass of page')
    else
      return klass
    end
  end

  # returns a string representation of page class based on the tool_type.
  # if the result in ambiguous, all matching classes are returned as an array.
  # for example:
  #   'poll/rate many' returns 'Tool::RateMany'
  #   'poll'           returns ['Tool::RateOne', 'Tool::RateMany']
  def tool_class_str(tool_type)
    ary = TOOLS.collect{|tool_class| tool_class.to_s if (tool_class.tool_type.starts_with?(tool_type) and not tool_class.internal?)}.compact
    return ary.first if ary.length == 1
    return ary
  end
  
  # override standard url_for to cache the result.
  #def url_for(options = {})
  #  @@cached_urls ||= {}
  #  return(@@cached_urls[options.to_yaml] ||= super(options))
  #end

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
  
  protected
  
  # to be written by controllers that display pages
  # called before breadcrumbs
  def fetch_page; end 
  
  # a before filter to override by controllers
  def breadcrumbs; end
  
  def add_crumb(crumb_text,crumb_url)
    @breadcrumbs ||= []
    @breadcrumbs << [crumb_text,crumb_url]
  end
  
  # builds conditions for findings pages based on filter path.
  # for example: /starred/type/event would search for pages that are starred, of type event.
  # order does not matter: the above is equivalent to /type/event/starred
  # The actual find might be through the Page, GroupParticipation, or UserParticipation table.
  # 
  def page_query_from_filter_path(options={})
    klass      = options[:class]
    path       = options[:path]
    conditions = [options[:conditions]]
    values     = options[:values]
    
    # filters
    while folder = path.pop
      if folder == 'unread'
        conditions << 'viewed = ?'
        values << false
      elsif folder == 'pending'
        if klass == UserParticipation
          conditions << 'user_participations.resolved = ?'
        else
          conditions << 'pages.resolved = ?'
        end
        values << false
      elsif folder == 'starred'
        if klass == UserParticipation
          conditions << 'user_participations.star = ?'
        else
          conditions << 'user_parts.star = ?'
        end
        values << true
      elsif folder == 'upcoming'
        conditions << 'pages.happens_at > ?'
        values << Time.now
      elsif folder == 'ago'
        near = path.pop.to_i.days.ago
        far  = path.pop.to_i.days.ago
        conditions << 'pages.updated_at < ? and pages.updated_at > ? '
        values << near
        values << far
      elsif folder == 'type'
        page_class = tool_class_str(path.pop)
        conditions << 'pages.type IN (?)'
        values << page_class
      elsif folder == 'person'
        conditions << 'user_parts.user_id = ?'
        values << path.pop
      elsif folder == 'group'
        conditions << 'group_parts.group_id = ?'
        values << path.pop
      end
      
      # sorting
      order = 'pages.updated_at DESC' # hard coded for now
    end
    
    # add in join tables:
    # if the conditions use user or group participations to limit which pages are returned,
    # then we must join in those tables. we don't use :include because we don't want the data,
    # we just want to be able to add conditions to the query. We alias the tables because 
    # user_participations or group_participations might already be included as the main table, so
    # we have to give it a new name.
    conditions_string = conditions.join(' AND ')
    join = ''
    if /user_parts\./ =~ conditions_string
      join += " LEFT OUTER JOIN user_participations user_parts ON user_parts.page_id = pages.id"
    end
    if /group_parts\./ =~ conditions_string
      join += " LEFT OUTER JOIN group_participations group_parts ON group_parts.page_id = pages.id"
    end
    
    { :conditions => [conditions_string] + values,
      :joins => join, :order => order, :class => klass }
  end
  
  # executes the actual find based on the output of page_query_from_filter_path
  def find_and_paginate_pages(options)
    klass = options[:class]
    per_page = 30
    options[:include] = :page unless klass == Page
    count = klass.count(:all,
      :conditions => options[:conditions],
      :joins      => "LEFT OUTER JOIN pages ON pages.id = #{klass.to_s.underscore}s.page_id " +
                     options[:joins]
    )
    page_sections = Paginator.new self, count, per_page, params[:section]
    offset = page_sections.current.offset
    pages = klass.find(:all,
      :conditions => options[:conditions],
      :joins      => options[:joins],
      :order      => options[:order],
      :include    => options[:include],
      :limit      => per_page,
      :offset     => offset
    )
    return([pages, page_sections])
  end
  
end
