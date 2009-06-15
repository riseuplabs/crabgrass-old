class CustomAppearancesController < ApplicationController
  stylesheet :custom_appearance
  javascript :extra
  helper ColorPickerHelper, Admin::UsersHelper, Admin::GroupsHelper, Admin::EmailBlastsHelper, Admin::AnnouncementsHelper, Admin::PagesHelper, Admin::PostsHelper
  permissions 'custom_appearances'

  before_filter :view_setup, :except => [:favicon, :available]
  before_filter :login_required, :except => [:favicon]
  prepend_before_filter :fetch_data, :except => [:favicon]

  # GET edit_custom_appearance_url
  def edit
    render :layout => 'admin'
  end

  # PUT custom_appearance_url
  def update
    begin
      @appearance.update_attributes!(params[:custom_appearance])
      flash_message :title => "Success".t,
        :success => "Updated custom appearance #:appearance_id options!"[:succesfully_updated_custom_appearance] % {:appearance_id => @appearance.id }
    rescue Exception => exc
      flash_message :object => @appearance
    end

    redirect_to :action => 'edit', :tab => @selected_tab
  end

  def available
    @variables = CustomAppearance.available_parameters
  end

protected
  def fetch_data
    @appearance = CustomAppearance.find(params[:id])
  end

  def view_setup
    @selected_tab = params['tab'] || 'masthead'
  end

end
