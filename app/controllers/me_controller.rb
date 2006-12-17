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
  
end
