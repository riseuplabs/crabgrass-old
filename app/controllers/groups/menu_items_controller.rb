class Groups::MenuItemsController < Groups::BaseController
  javascript 'effects', 'dragdrop', 'controls', 'autocomplete' # require for find page autocomplete
  helper 'groups'
  before_filter :fetch_data, :login_required
  before_render :load_menu_items

  verify :only => :update, :method => :put, :redirect_to => {:action => :index}

  def index
  end

  # GET /menu_items/1
  # GET /menu_items/1.xml
  def show
    @menu_item = MenuItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      #format.xml  { render :xml => @menu_item }
    end
  end

  # GET /menu_items/new
  # GET /menu_items/new.xml
  def new
    @menu_item = MenuItem.new

    respond_to do |format|
      format.html # new.html.erb
      #format.xml  { render :xml => @menu_item }
    end
  end

  # GET /menu_items/1/edit
  def edit
    @menu_item = MenuItem.find(params[:id])
  end

  def create
    @group.add_menu_item(params[:menu_item])
    @menu_items=@group.menu_items
  end

  def update
    menu_item_ids = params[:menu_items_ids].collect(&:to_i)

    menu_item_ids.each_with_index do |id, position|
      # find the menu_item with this id
      menu_item = MenuItem.find(id)
      menu_item.update_attribute(:position, position)
    end
  end

  def destroy
    @menu_item = MenuItem.find(params[:menu_item_id])
    @menu_item.destroy
  end

  def load_menu_items
    @menu_items = @group.menu_items
  end

  def fetch_data
    # must have a group
    @group = Group.find_by_name(params[:id])
  end

  def context
    group_settings_context
  end

  def authorized?
    may_edit_menu?
  end

end
