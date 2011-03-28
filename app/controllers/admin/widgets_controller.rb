class Admin::WidgetsController < Admin::BaseController

  helper :widgets, 'modalbox'
  permissions 'widgets'
  before_filter :fetch_profile
  javascript :extra

  # GET /admin/widgets
  def index
    @main_widgets = @profile.widgets.find_all_by_section 1
    @sidebar_widgets = @profile.widgets.find_all_by_section 2
    @main_storage_widgets = @profile.widgets.find_all_by_section 3
    @sidebar_storage_widgets = @profile.widgets.find_all_by_section 4
  end

  def sort
    section, ids = params.detect{|k,v| /^sort_list_/.match(k)}
    @profile.widgets.sort_section(section, ids)
  end

  protected

  def fetch_profile
    @group = current_site.network if current_site and current_site.network
    @profile = @group.profiles.public
  end

end
