class CustomAppearancesController < ApplicationController
  stylesheet :custom_appearance
  javascript :extra
  helper ColorPickerHelper

  before_filter :login_required
  prepend_before_filter :fetch_data

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

    redirect_to :action => 'edit'
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
    return true if @appearance.admin_group and current_user.member_of?(@appearance.admin_group)

    if current_site and @appearance == current_site.custom_appearance and current_site.super_admin_group_id
      admin_group = Group.find(current_site.super_admin_group_id)
      if admin_group and current_user.may?(:admin, admin_group)
        return true
      end
    end

    return false
  end
end
