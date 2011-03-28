class MenuItemsController < ApplicationController
  javascript 'effects', 'dragdrop', 'controls', 'autocomplete' # require for find page autocomplete
  prepend_before_filter :fetch_data
  before_filter :login_required
  before_filter :load_menu_items
  stylesheet 'menu_items'
  permissions 'widgets'

  verify :only => :update, :method => :put

  # not used yet.
  #def show
  #end

  # we are not using this right now. there is a
  # new empty menu item displayed at the end of the
  # list.
  #def new
  #  @menu_item = MenuItem.new
  #  @menu_item.position = @group.menu_items.count
  #end

  def edit
  end

  def create
    if @menu_item=@menu_items.create!(params[:menu_item])
      @parent = @menu_item.parent
      flash[:notice] = 'Menu item was successfully created.'
    end
    render_parent_form
  end

  def update
    @menu_item.update_attributes(params[:menu_item])
    render_parent_form
  end

  # changing the order of menu_items via drag&drop.
  def sort
    @menu_items.update_order(params[:menu_items_list])
    flash[:notice] = 'Menu items have been reordered.'
    render :action => :index unless request.xhr?
  end

  def destroy
    @menu_item.destroy
  end

  protected

  # this also makes sure that @menu_item belongs to the profile if an
  # id is given.
  def load_menu_items
    @menu_items = @widget.menu_items
    if params[:id]
      @menu_item = @menu_items.find(params[:id])
    end
  end

  def fetch_data
    # must have a widget
    @widget = Widget.find(params[:widget_id])
    @profile = @widget.profile
    @entity = @profile.entity
  end

  def authorized?
    may_edit_widget?
  end

  def render_parent_form
    if request.xhr?
      render
    elsif @parent
      render :action => :edit
    else
      redirect_to :controller => :widget, :action => :index, :id => @widget.id
    end
  end
end
