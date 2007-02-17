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
        @user.avatar.destroy if @user.avatar
        @user.avatar = avatar
        @user.save
      end
    end
    render :action => 'edit'
  end
  
  protected
  
  def breadcrumbs
    @user = current_user
    add_crumb 'me', me_url(:action => 'index')
    unless ['show','index'].include?(params[:action])
      add_crumb params[:action], me_url(:action => params[:action])
    end
  end
end
