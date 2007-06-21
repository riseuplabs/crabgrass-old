# PagesController
# ---------------------------------
#
# Controller for managing abstract pages. The display and editing of
# a particular page type (aka tool) are handled by controllers
# in controllers/tool.
#
# When should an action be in this controller or in Tool::Base?
# The general rule is this:
#
#    If the action can go in PagesController, then do so.
#
# This means that only stuff specific to a tool should go in the
# tool controllers.
# 
# For example, there are two create actions, one in PagesControllers
# and one in Tool::Base. The one in PagesController handles the first
# step where you choose a page type. The one in Tool::Base handles the
# next step where you enter in data. This step is handled by Tool::Base
# so that each tool can define their own method of creation.
#

class PagesController < ApplicationController

  prepend_before_filter :fetch_page

  # if this controller is called by DispatchController,
  # then we may be passed some objects that are already loaded.
  def initialize(options={})
    super()
    @pages = options[:pages] # a list of pages, if already fetched
  end  

  # a simple form to allow the user to select which type of page
  # they want to create. the actual create form is handled by
  # Tool::BaseController (or overridden by the particular tool). 
  def create
  end
  
  def create_new_page
    groups    = get_groups
    users     = get_users
    page_type = get_page_type
    
    page = page_type.new params[:page].merge({:created_by_id => current_user.id})
    groups.each do |group|
      page.add(group, :access => ACCESS_ADMIN)
      users += group.users if params[:announce]
    end
    users.uniq.each do |u|
      if u.member_of? groups
        page.add(u)
      else
        page.add(u, :access=>ACCESS_ADMIN)
      end
    end
    page.tag_with(params[:tag_list]) if params[:tag_list]
    page
  end  
    
  # not used anymore
  def add_tags
    tags = Tag.parse(params[:new_tags]) + @page.tags.collect{|t|t.name}
    @page.tag_with(tags.uniq.join(' '))
    @page.save 
    redirect_to page_url(@page)
  end
  
  def tag
    return unless request.xhr?
    tags = Tag.parse(params[:tag_list])
    @page.tag_with(tags.uniq.join(' '))
    @page.save
    render :partial => "pages/tags"
  end
  
  def search
    unless @pages
      if logged_in?
        options = options_for_pages_viewable_by(current_user)
      else
        options = options_for_public_pages
      end
      options.merge!( {:class => Page, :path => params[:path]} )
      @pages, @page_sections = find_and_paginate_pages(options)
    end
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
  def announce
    @errors = []; @infos = []
    params[:announcees].split(/\W+/).each do |name|
      entity = Group.get_by_name(name) || User.find_by_login(name)
      if entity
        if entity.may?(:view, @page)
          @page.add(entity.users) if entity.instance_of? Group
          @page.add(entity) if entity.instance_of? User
          @infos << name
        else
          @errors << "%s is not allowed to view this page." % entity.name
        end
      else
        @errors << "'%s' is not the name of a group or a person." % name
      end
    end
  end

  def access
    if request.post?
      if params[:remove_group]
        @page.remove(Group.find_by_id(params[:remove_group]))
      elsif params[:remove_user]
        @page.remove(User.find_by_id(params[:remove_user]))
      elsif params[:add_name]
        access = params[:access] || ACCESS_ADMIN
        if group = Group.get_by_name(params[:add_name])
          @page.add group, :access => access
        elsif user = User.find_by_login(params[:add_name])
          @page.remove user
          @page.add user, :access => access
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
  def mark_public
    @page.update_attribute(:public, true)
    render :partial => 'public'
  end
  
 # only works with xhr for now.
  def mark_private
    @page.update_attribute(:public, false)
    render :partial => 'public'
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
    if request.post?
      @page.data.destroy if @page.data # can this be in page?
      @page.destroy
    end
    redirect_to from_url(@page)
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
    return true unless request.get?
    @group ||= Group.find_by_id(params[:group_id]) if params[:group_id]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user 
    page_context
    true
  end
  
  def get_groups
    if params[:group_name].any?
      group = Group.get_by_name params[:group_name]
      raise Exception.new('no such group %s' % params[:group_name]) if group.nil?
      [group]
    elsif params[:group_id].any?
      group = Group.find_by_id params[:group_id]
      raise Exception.new('no such group') if group.nil?
      [group]
    else
      []
    end
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    raise Exception.new('page type required') unless params['page_type']
    return get_tool_class(params['page_type'])
  end
  
  def fetch_page
    @page = Page.find_by_id(params[:id]) if params[:id]
    @upart = (@page.participation_for_user(current_user) if logged_in? and @page)
    true
  end
  
end
