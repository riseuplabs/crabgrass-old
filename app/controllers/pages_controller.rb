=begin

PagesController
---------------------------------

This is a controller for managing abstract pages. The display and editing of
a particular page type (aka tool) are handled by controllers in controllers/tool.

When should an action be in this controller or in Tool::Base?
The general rule is this:

   If the action can go in PagesController, then do so.

This means that only stuff specific to a tool should go in the
tool controllers.

For example, there are two create() actions, one in PagesControllers
and one in Tool::Base. The one in PagesController handles the first
step where you choose a page type. The one in Tool::Base handles the
next step where you enter in data. This step is handled by Tool::Base
so that each tool can define their own method of creation.

=end

class PagesController < ApplicationController

  helper Tool::BaseHelper
  
  before_filter :login_required, :except => 'search'
  prepend_before_filter :fetch_page

  # if this controller is called by DispatchController,
  # then we may be passed some objects that are already loaded.
  def initialize(options={})
    super()
    @pages = options[:pages] # a list of pages, if already fetched
  end  

  ##############################################################
  ## PUBLIC ACTIONS
  
  def search
    unless @pages
      if logged_in?
        options = options_for_me
      else
        options = options_for_public_pages
      end
      @pages, @page_sections = Page.find_and_paginate_by_path(params[:path], options)
    end
  end

  # a simple form to allow the user to select which type of page
  # they want to create. the actual create form is handled by
  # Tool::BaseController (or overridden by the particular tool). 
  def create
  end
     
  def tag
    return unless request.xhr?
    @page.tag_with(params[:tag_list])
    @page.save
  rescue Tag::Error => @error
  ensure
    render :partial => "pages/tags"
  end
    
  # for quickly creating a wiki
  def create_wiki
    group = Group.get_by_name(params[:group])
    if !logged_in?
      message :error => 'You must first login.'
    elsif group.nil?
      message :error => 'Group does not exist.'
    elsif !current_user.member_of?(group)
      message :error => "You don't have permission to create a page for that group"
    else
      page = Page.make :wiki, {:user => current_user, :group => group, :name => params[:name]}
      page.save
      redirect_to page_url(page)
      return
    end
    render :text => '', :layout => 'application'
  end


  # send an announcement to users about this page.
  # in other words, send to their inbox.
  # requires: login, view access
  def notify
    @errors = []; @infos = []
    params[:to].split(/\s+/).each do |name|
      next unless name.any?
      entity = Group.get_by_name(name) || User.find_by_login(name)
      if entity.nil?
        @errors << "'%s' is not the name of a group or a person." / name
        next
      end
      if @page.public?
        unless current_user.may_pester?(entity)
          @errors << "%s is not allowed to notify %s.".t % [current_user.login, entity.name]
          next
        end
      else
        unless entity.may?(:view, @page)
          @errors << "%s is not allowed to view this page." / entity.name
          next
        end
      end
      notice = params[:message] ? {:user_login => current_user.login, :message => params[:message], :time => Time.now} : nil
      if entity.instance_of? Group
        @page.add(entity.users - [current_user], :notice => notice) if entity.users.any?
      elsif entity.instance_of? User
        @page.add(entity, :notice => notice)
      end
      @infos << name
    end
  end

  def access
    if request.post?
      if params[:remove_group]
        @page.remove(Group.find_by_id(params[:remove_group]))
      elsif params[:remove_user]
        @page.remove(User.find_by_id(params[:remove_user]))
      # maybe we shouldn't allow removal of last entity (?) -- now handled in view -af
      elsif params[:add_name]
        access = params[:access] || :admin
        if group = Group.get_by_name(params[:add_name])
          if current_user.may_pester? group
            @page.add group, :access => access
          else
            message :error => 'you do not have permission to do that'
          end
        elsif user = User.find_by_login(params[:add_name])
          if current_user.may_pester? user
            @page.remove user
            @page.add user, :access => access
          else
            message :error => 'you do not have permission to do that'
          end
        else
          message :error => 'group or user not found'
        end
      end
      @page.save
    end
  end

  def participation
    
  end
  
  def history
  
  end

  # assigns a page to a different group. 
  # we only allow assignments between committees of the same group
  # or between the parent group and a committee.
  def move
    return unless request.post?
    group = Group.find params[:group_id]
    if group.committee? and @page.group.committee?
      ok = group.parent == @page.group.parent
    elsif group.committee? and !@page.group.committee?
      ok = @page.group.committees.include? group
    elsif !group.committee? and @page.group.committee?
      ok = group.committees.include? @page.group
    else
      ok = false
    end
    if ok
      @page.remove(@page.group)
      @page.add(group)
      @page.group = group
      @page.save
      clear_referer(@page)
    end
    redirect_to page_url(@page)
  end


  # only works with xhr for now.
  def update_public
    @page.update_attribute(:public, ('true' == params[:public]))
    current_user.updated @page
    # in the future, indicate that the page was changed by making it public
    render :nothing => true
  end
  
  ##############################################
  ## page participation modifications
  
  def remove_from_my_pages
    @upart.destroy
    redirect_to from_url(@page)
  end
  
  def add_to_my_pages
    @page.add(current_user)
    redirect_to page_url(@page)
  end
  
  def make_resolved
    @upart.resolved = true
    @upart.save
    redirect_to page_url(@page)
  end
  
  def make_unresolved
    @upart.resolved = false
    @upart.save
    redirect_to page_url(@page)
  end  
  
  def add_star
    @upart.star = true
    @upart.save
    redirect_to page_url(@page)
  end
  
  def remove_star
    @upart.star = false
    @upart.save
    redirect_to page_url(@page)
  end  
    
  def destroy
    return unless request.post?
    url = from_url(@page)
    @page.data.destroy if @page.data # can this be in page?
    @page.destroy
    redirect_to url
  end

  protected
  
  def authorized?
    # see BaseController::authorized?
    if @page
      return current_user.may?(:admin, @page)
    else
      return true
    end
  end

  def context
#    return true unless request.get?  #I don't know what the purpose of this is, but commenting it out makes access look better after removing access  --af
    @group ||= Group.find_by_id(params[:group_id]) if params[:group_id]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user 
    page_context
    true
  end
  
  def fetch_page
    @page = Page.find_by_id(params[:id]) if params[:id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
    true
  end
  
end
