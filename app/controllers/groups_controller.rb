class GroupsController < ApplicationController

  before_filter :find_group
  
  def index
    list
    render :action => 'list'
  end

  verify :method => :post,
    :only => [ :destroy, :create, :add_user, :remove_user, :join_group, :leave_group ]

  def list
    @group_pages, @groups = paginate :groups, :per_page => 10
  end

  def show
    params[:path] = []
    folder()
  end

  def folder
    options = {:class => GroupParticipation, :path => params[:path]}
    if logged_in?
      # the group's pages that we also have access to
      options[:conditions] = "(group_participations.group_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?))"
      options[:values]     = [@group.id, current_user.group_ids, current_user.id, true]
    else
      # the group's public pages
      options[:conditions] = "group_participations.group_id = ? AND pages.public = ?"
      options[:values]     = [@group.id, true]
    end
    @pages, @page_sections = find_and_paginate_pages page_query_from_filter_path(options)
    render :action => 'show'
  end
  
  # GroupParticipation.find(:all, :joins => "LEFT OUTER JOIN group_participations group_participations_pages ON group_participations_pages.page_id = pages.id LEFT OUTER JOIN user_participations ON user_participations.page_id = pages.id", :conditions => "group_participations.group_id = 1 and (group_participations_pages.group_id in (3) or user_participations.user_id = 4)", :include => :page ) 

  def new
    @group = Group.new
  end


  def create
    @group = Group.new(params[:group])
    if @group.save
      message :success => 'Group was successfully created.'
      @group.users << current_user 
      redirect_to :action => 'show', :id => @group
    else
      message :object => @group
      render :action => 'new'
    end
  end

  def edit
    if request.post? 
      if @group.update_attributes(params[:group])
        redirect_to :action => 'edit', :id => @group
        message :success => 'Group was successfully updated.'
      else
        message :object => @group
      end
    end
  end
  
  
  def update
    @group.update_attributes(params[:group])
    redirect_to :action => 'show', :id => @group
  end

  def invite
    return unless request.post?
    wrong = []
    sent = []
    params[:users].split(/\s/).each do |login|
      next if login.empty?
      if user = User.find_by_login(login)
        page = Page.make :invite_to_join_group, :group => @group, :user => user, :from => current_user
        page.save
        sent << login
      else
        wrong << login
      end
    end
    if wrong.any?
      message :later => true, :error => "These invites could not be sent because the user names don't exist: " + wrong.join(', ')
    elsif sent.any?
      message :success => 'Invites sent: ' + sent.join(', ')
    end
    redirect_to :action => 'show', :id => @group
  end
  
#  def avatar
#    if request.post?
#      avatar = Avatar.create(:data => params[:image][:data])
#      if avatar.valid?
#        @group.avatar.destroy if @group.avatar
#        @group.avatar = avatar
#        @group.save
#        redirect_to :action => 'edit', :id => @group
#        return
#      end
#    end
#    render :action => 'edit'
#  end


  # post only
  def add_user
    user = User.find_by_login params[:login]
    page = Page.make :invite_to_join_group, :user => user, :group => @group, :from => current_user
    if page.save
      message :success => "Invitation sent"
      redirect_to group_url(:action => 'edit', :id => group)
    else
      message :object => page
      render :action => 'edit'
    end
  end
  
  # post only
  def remove_user
    user = User.find_by_login params[:login]
    @group.users.delete(user)
    message :success => 'User %s removed from group %s'.t % [user.login, @group.name]
    redirect_to group_url(:action => 'edit', :id => @group)
  end
  
  # post only
  def join_group
    unless @group.users.any?
      # if the group has no users, then let the first person join.
      @group.users << current_user
      message :success => 'You are the first pers:rows => 8, :cols => 60on in this group'
      redirect_to :action => 'show', :id => @group
      return
    end
    page = Page.make :request_to_join_group, :user => current_user, :group => @group
    if page.save
      message :success => 'Your request to join this group has been sent.'
      page = Page.make :join_sent_notice, :user => current_user, :group => @group
      page.save
      redirect_to group_url(:action => 'show', :id => @group)
    else
      message :object => page
      render :action => 'show'
    end
  end
  
  # post only
  def leave_group
    group = Group.find(params[:id])
    current_user.groups.delete(group)
    message :success => 'You have been removed from %s' / group.name
    redirect_to me_url
  end
  
  # post only
  def destroy
    if @group.users.size > 1 or @group.users.first != current_user
      message :error => 'You can only delete a group if you are the last member'
      redirect_to :action => 'show', :id => @group
    else
      Group.find(params[:id]).destroy      
      redirect_to :action => 'list'
    end
  end  
    
  protected
  
  def breadcrumbs
    @group = Group.find_by_id(params[:id])
    add_crumb 'groups', groups_url(:action => 'list')
    add_crumb @group.name, groups_url(:id => @group, :action => 'show') if @group
    unless ['show','index','list'].include? params[:action]
      add_crumb params[:action], groups_url(:action => params[:action], :id => @group)
    end
  end
  
  def find_group
    @group = Group.find_by_id params[:id]
  end
  
end
