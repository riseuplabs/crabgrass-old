class Admin::GroupsController < Admin::BaseController

  before_filter :fetch_group_by_name, :only => [ :show, :edit, :update, :destroy ]

  permissions 'admin/super'

  cache_sweeper :social_activities_sweeper, :only => [:update, :create, :destroy]

  # GET /groups
  # GET /groups.xml
  def index
    @letter = (params[:letter] || '')
    @groups = Group.alphabetized(@letter).find(:all)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])

    # save avatar
    avatar = Avatar.create(params[:image])
    @group.avatar = avatar

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update

    # save or update avatar
    if @group.avatar && params[:image_file]
      for size in %w(xsmall small medium large xlarge)
        expire_page :controller => 'static', :action => 'avatar', :id => @group.avatar.id, :size => size
      end
      @group.avatar.image_file = params[:image_file]
      @group.avatar.save!
    elsif params[:image_file]
      avatar = Avatar.create(:image_file => params[:image_file])
      @group.avatar = avatar
    end

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group.destroy_by(current_user)

    respond_to do |format|
      format.html { redirect_to(groups_path) }
      format.xml  { head :ok }
    end
  end

  private
  def fetch_group_by_name
    @group = Group.find_by_name(params[:id])
  end

end
