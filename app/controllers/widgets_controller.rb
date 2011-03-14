class WidgetsController < ApplicationController

  helper :widgets, 'modalbox', 'menu_items'
  permissions 'widgets'
  before_filter :fetch_profile
  before_filter :login_required
  layout :no_layout_for_ajax

  # GET /widgets/1
  def show
    @widget = @profile.widgets.find(params[:id])
  end

  # GET /widgets/new
  def new
    @widget = @profile.build_widget
  end

  # GET /widgets/1/edit
  def edit
    @widget = @profile.widgets.find(params[:id])
  end

  # POST /widgets
  def create
    @widget = profile.build_widget(params[:widgets])

    if @widget.save
      flash[:notice] = 'Widget was successfully created.'
      redirect_to(@widget)
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
    @widget = @profiel.widgets.find(params[:id])
    @widgets.destroy
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
