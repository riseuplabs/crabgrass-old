class Admin::UsersController < Admin::BaseController

  before_filter :fetch_user_by_login, :only => [ :show, :edit, :update, :destroy ]

  permissions 'admin/super'

  # GET /users
  # GET /users.xml
  def index
    @letter = (params[:letter] || '')
    if params[:show] == 'active'
      @users = User.on(current_site).alphabetized(@letter).active_since(1.month.ago).paginate(:page => params[:page])
      @pagination_letters = (User.on(current_site).active_since(1.month.ago).logins_only).collect{|u| u.login.first.upcase}.uniq
    elsif params[:show] == 'inactive'
      @users = User.on(current_site).inactive_since(1.month.ago).alphabetized(@letter).paginate(:page => params[:page])
      @pagination_letters = (User.on(current_site).inactive_since(1.month.ago).logins_only).collect{|u| u.login.first.upcase}.uniq
    else
      @users = User.on(current_site).alphabetized(@letter).paginate(:page => params[:page])
      @pagination_letters = (User.on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    end
    @show = params[:show]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.save!

    # save avatar
    avatar = Avatar.create(params[:image])
    @user.avatar = avatar

    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  rescue Exception => exc
    render :action => 'new'
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update

    # save or update avatar
    if @user.avatar
      for size in %w(xsmall small medium large xlarge)
        expire_page :controller => 'static', :action => 'avatar', :id => @user.avatar.id, :size => size
      end
      @user.avatar.image_file = params[:image][:image_file]
      @user.avatar.save!
    else
      avatar = Avatar.create(params[:image])
      @user.avatar = avatar
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_path) }
      format.xml  { head :ok }
    end
  end

  private
  def fetch_user_by_login
    @user = User.find_by_login(params[:id])
  end
end
