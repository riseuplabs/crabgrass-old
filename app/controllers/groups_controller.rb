class GroupsController < ApplicationController

  before_filter :find_group
  
  def index
    list
    render :action => 'list'
  end

  verify :method => :post,
    :only => [ :destroy, :create, :add_user, :remove_user, :join_group, :leave_group ],
    :redirect_to => { :action => :list }

  def list
    @group_pages, @groups = paginate :groups, :per_page => 10
  end

  def show
  end

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
      else
        message :object => @group
      end
    end
  end

  def avatar
    if request.post?
      avatar = Avatar.create(:data => params[:image][:data])
      if avatar.valid?
        @group.avatar.destroy if @group.avatar
        @group.avatar = avatar
        @group.save
        redirect_to :action => 'edit', :id => @group
        return
      end
    end
    render :action => 'edit'
  end


  # post only
  def add_user
    group = Group.find params[:id]
    user = User.find_by_login params[:login]
    page = Page.make :invite_to_join_group, :user => user, :group => group, :from => current_user
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
    group = Group.find params[:id]
    user = User.find_by_login params[:login]
    group.users.delete(user)
    message :success => 'User %s removed from group %s'.t % [user.login, group.name]
    redirect_to group_url(:action => 'edit', :id => group)
  end
  
  # post only
  def join_group
    group = Group.find(params[:id]) 
    page = Page.make :request_to_join_group, :user => current_user, :group => group
    if page.save
      message :success => 'Your request to join this group has been sent.'
      redirect_to group_url(:action => 'show', :id => group)
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
  
  def destroy
    Group.find(params[:id]).destroy
    redirect_to :action => 'list'
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
