class Admin::GroupsController < Admin::BaseController
  # GET /groups
  # GET /groups.xml
  def index
    filter = '^'+(params[:filter] || '')
    # special case: numbers
    filter = '^[0-9]' if filter == '^#'
    @groups = Group.find(:all, :conditions => ['groups.name REGEXP(?)', filter])
    @active = 'edit_groups'
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find_by_name(params[:id])
    @active = 'edit_groups'
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    @active = 'create_groups'
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @active = 'edit_groups'
    @group = Group.find_by_name(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  def create
    @active = 'create_groups'
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
    @active = 'edit_groups'
    @group = Group.find_by_name(params[:id])
    
    # save or update avatar
    if @group.avatar
      for size in %w(xsmall small medium large xlarge)
        expire_page :controller => 'static', :action => 'avatar', :id => @group.avatar.id, :size => size
      end
      @group.avatar.image_file = params[:image][:image_file]
      @group.avatar.save!
    else
      avatar = Avatar.create(params[:image])
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
    @active = 'edit_groups'
    @group = Group.find_by_name(params[:id])
    @group.destroyed_by = current_user
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_path) }
      format.xml  { head :ok }
    end
  end
end
