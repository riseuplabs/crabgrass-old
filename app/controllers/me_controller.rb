class MeController < ApplicationController

  def index
    @user = current_user
  end

  def urgent
    @user = current_user
    render :action => 'index'
  end
  
  def search
    @user = current_user
    render :action => 'index'
  end

  def add_contact
    @user = current_user
    other = User.find_by_login params[:id]
    current_user.contacts << other
    render :action => 'index'
  end
  
  def remove_contact
    @user = current_user
    other = User.find_by_login params[:id]
    current_user.contacts.delete(other)
    render :action => 'index'
  end
  
  # this is just a permissionless stub until something 
  # real exists.
  def join_group
    @user = current_user
    @user.groups << Group.find(params[:id])
    render :action => 'index'
  end
  
  def leave_group
    @user = current_user
    @user.groups.delete(Group.find(params[:id]))
    render :action => 'index'
  end
  
  def edit
    @user = current_user
    if request.post? 
      @user.update_attributes(params[:user])
      groups = params[:name].split(/[,\s]/)
      for group in groups
        @new_group = Group.find(:all, :conditions =>["name = ?",group])
        @user.groups << @new_group unless @user.groups.find_by_name group
        if @new_group.nil?
          flash[:notice] = 'Group %s does not exist.' %group
        end
      end
      flash[:notice] = 'User was successfully updated.'
    end
  end

  def avatar
    if request.post?
      avatar = Avatar.create(:data => params[:image][:data])
      if avatar.valid?
        @user.avatars.clear
        @user.avatars << avatar
      end
    end
    render :action => 'edit'
  end
  
  protected
  
  def breadcrumbs
    @user = current_user
    add_crumb 'me', me_url(:action => 'index')
    unless ['show','index'].include? params[:action]
      add_crumb params[:action], me_url(:action => params[:action])
    end
  end
end
