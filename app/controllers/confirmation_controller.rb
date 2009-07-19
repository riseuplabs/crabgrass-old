class ConfirmationController < ActionController::Base
  # renders an modalbox enabled template, to show a confirmation dialoque
  # needs to be accessable in several controllers
  
  verify :method => :get, :only => [:confirmation_popup]
  
  def confirmation_popup
    @confirmatione_title = params[:confirmation_title]
    @confirmation_text = params[:confirmation_text]
    @confirmation_url = params[:confirmation_url]
    render :partial => 'common/confirmation_popup'
  end
end
