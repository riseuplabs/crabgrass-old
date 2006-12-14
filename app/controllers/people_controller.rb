class PeopleController < ApplicationController

  model :user

  def index
    list
    render :action => 'list'
  end

  def list
   # @user_pages, @users = paginate :users, :per_page => 10
    @contacts = current_user.contacts
    @in_common = current_user.users_in_common_groups
  end

  def view
    @user = User.find_by_login params[:id]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    if request.post? 
      @user.update_attributes(params[:user])
      groups = params[:name].split  /[,\s]/
      for group in groups
        @new_group = Group.find(:all, :conditions =>["name = ?",group])
        @user.groups << @new_group unless @user.groups.find_by_name group
        if @new_group.nil?
	  flash[:notice] = 'Group %s does not exist.' %group
	end
      end
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    end
  end


  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
