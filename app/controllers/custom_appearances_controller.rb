class CustomAppearancesController < ApplicationController
  before_filter :login_required
  prepend_before_filter :fetch_data

  # GET edit_custom_appearance_url
  def edit

  end

  # PUT custom_appearance_url
  def update
    @appearance.parameters = params[:custom_appearance][:parameters]
    @appearance.save!
    flash_message :title => "Success", :success => "Updated custom appearance #{@appearance.id} options!"
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
    true if logged_in? and @appearance.admin_group and current_user.member_of?(@appearance.admin_group)
  end
end
