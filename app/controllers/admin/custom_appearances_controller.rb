class Admin::CustomAppearancesController < Admin::BaseController
  stylesheet :custom_appearance
  javascript :extra

  helper ColorPickerHelper, Admin::UsersHelper, Admin::GroupsHelper, Admin::EmailBlastsHelper, Admin::AnnouncementsHelper, Admin::PagesHelper, Admin::PostsHelper, 'custom_appearances', 'admin/custom_appearances'
  permissions 'admin/custom_appearances'

  verify :method => [:post, :put], :only => [:update]
  before_filter :view_setup, :except => [:favicon, :available]
  before_filter :login_required, :except => [:favicon]
  prepend_before_filter :fetch_data, :except => [:favicon, :new]

  def new
    unless current_site.custom_appearance
      current_site.create_custom_appearance
      current_site.save
    end
    redirect_to edit_admin_custom_appearance_url(current_site.custom_appearance)
  end

  # GET edit_custom_appearance_url
  def edit
    @admin_active_tab = 'custom_appearances_edit'
    @active_tab = :admin
    #render :layout => 'admin'
  end

  # PUT custom_appearance_url
  def update
    begin
      @appearance.update_attributes!(params[:custom_appearance])
      flash_message :title => I18n.t(:success),
        :success => I18n.t(:succesfully_updated_custom_appearance, :appearance_id => @appearance.id )
    rescue Exception => exc
      flash_message :object => @appearance
    end

    redirect_to :action => 'edit', :tab => @selected_tab
  end

  def available
    @variables = CustomAppearance.available_parameters("ui_base")
  end

protected
  def fetch_data
    @appearance = CustomAppearance.find(params[:id])
  end

  def view_setup
    @selected_tab = params['tab'] || 'masthead'
  end

end
