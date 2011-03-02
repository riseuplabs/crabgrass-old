class Admin::WidgetsController < Admin::BaseController

  helper :widgets, 'modalbox'
  permissions 'widgets'
  before_filter :fetch_profile

  # GET /admin/widgets
  def index
    @main_widgets = @profile.widgets.find_all_by_section 1
    @sidebar_widgets = @profile.widgets.find_all_by_section 2
  end

  protected

  def fetch_profile
    @group = current_site.network if current_site and current_site.network
    @profile = @group.profiles.public
  end

end
