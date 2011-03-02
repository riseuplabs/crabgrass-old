class Admin::WidgetsController < Admin::BaseController

  helper :widgets, 'admin/widgets', 'modalbox'
  permissions 'widgets'
  before_filter :fetch_profile

  # GET /widgets
  def index
    @main_widgets = @profile.widgets.find_all_by_section 1
    @sidebar_widgets = @profile.widgets.find_all_by_section 2
  end

  # GET /widgets/1
  def show
    @widget = @profile.widgets.find(params[:id])
    render :partial => @widget.partial
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
    @widgets = @profile.widgets.find(params[:id])

    if @widgets.update_attributes(params[:widgets])
      flash[:notice] = 'Widgets was successfully updated.'
      redirect_to(@widgets)
    else
      render :action => "edit"
    end
  end

  # DELETE /widgets/1
  def destroy
    @widget = @profiel.widgets.find(params[:id])
    @widgets.destroy

    redirect_to(widgets_url)
  end

  protected

  def fetch_profile
    @group = current_site.network if current_site and current_site.network
    @profile = @group.profiles.public
  end

end
