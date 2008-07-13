class AccountController < ApplicationController

  def signup
    @user = User.new(params[:user])
    return unless request.post?

    if params[:social_contract][:accepted] != "yes"
      flash[:error] = "You must accept the social contract to create an account"
      return
    end
    
    @user.save!
    self.current_user = @user
    send_welcome_message(current_user)
    redirect_to params[:redirect] || {:controller => '/account', :action => 'welcome'}
    flash[:notice] = "Thanks for signing up!"
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

end
