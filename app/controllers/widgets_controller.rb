class WidgetsController < ApplicationController

  # we need most helpers from the root controller for the preview actions
  helper :widgets, 'modalbox', 'menu_items', 'locations', 'autocomplete', :groups, :account, :wiki, :page, :root
  permissions 'widgets', 'root', 'groups/base', 'wiki'
  before_filter :fetch_profile
  before_filter :login_required
  layout :no_layout_for_ajax

  # GET /widgets/1
  def show
    @widget = @profile.widgets.find(params[:id])
  end

  # GET /widgets/new
  def new
    @widget_names = Widget.for_columns(2).keys
    @widget = @profile.widgets.build(:section => 3)
  end

  # GET /widgets/new/sidebar
  def sidebar
    @widget_names = Widget.for_columns(1).keys
    @widget = @profile.widgets.build(:section => 4)
    render :action => :new
  end

  # GET /widgets/1/edit
  def edit
    @widget = @profile.widgets.find(params[:id])
    @menu_items=@widget.menu_items
  end

  # POST /widgets
  def create
    @widget = @profile.widgets.build(Widget.build_params(params))
    if params[:step] == '2'
      @widget.save
      flash[:notice] = 'Widget was successfully created.'
      redirect_to(admin_widgets_url)
    else
      render :action => "new"
    end
  end

  # PUT /widgets/1
  def update
    @widget = @profile.widgets.find(params[:id])

    if @widget.update_attribute :options, params[:widget].to_options
      flash[:notice] = 'Widget was successfully updated.'
      redirect_to(admin_widgets_url)
    else
      render :action => "edit"
    end
  end


  # DELETE /widgets/1
  def destroy
    @widget = @profile.widgets.find(params[:id])
    @widget.destroy
    redirect_to(admin_widgets_url)
  end

  protected

  def fetch_profile
    @group = current_site.network if current_site and current_site.network
    @profile = @group.profiles.public
  end

  def no_layout_for_ajax
    request.xhr? ? false : 'default'
  end
end
