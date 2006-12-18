class GroupsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @group_pages, @groups = paginate :groups, :per_page => 10
  end

  def show
    @group = Group.find(params[:id])
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @group = Group.find(params[:id])
    if request.post? 
      @group.update_attributes(params[:group])
      
      logins = params[:login].split  /[,\s]/
      for user in logins
          @new_user = User.find(:all, :conditions =>["login = ?",user])
	  @group.users << @new_user unless @group.users.find_by_login user
        if @new_user.nil?
	   flash[:notice] = 'User %s does not exist.' %user
	end
# (@new_user and not 
# @group.users.include?(@new_user))
      end
 #   flash_error 'group' #???
      flash[:notice] = 'Group was successfully updated.'
      redirect_to :action => 'show', :id => @group
    end
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to :action => 'show', :id => @group
    else
      render :action => 'edit'
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
