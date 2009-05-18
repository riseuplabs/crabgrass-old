class CustomAppearancesController < ApplicationController
  stylesheet :custom_appearance
  javascript :extra
  helper ColorPickerHelper

  before_filter :view_setup, :except => [:favicon, :available]
  before_filter :login_required, :except => [:favicon]
  prepend_before_filter :fetch_data, :except => [:favicon]

  # GET edit_custom_appearance_url
  def edit
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

  def authorized?
    return false unless logged_in?
    if current_site and @appearance == current_site.custom_appearance and current_site.super_admin_group
      if current_user.may?(:admin, current_site.super_admin_group)
        return true
      end
    end

    if current_site and @appearance == current_site.custom_appearance
      return true if current_user.may?(:admin, current_site)
    end

    return false
  end

  def view_setup
    @selected_tab = params['tab'] || 'masthead'
  end
end
