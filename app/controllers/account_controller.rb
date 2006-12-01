class AccountController < ApplicationController
  skip_before_filter :login_required
  
  def index
  end

  def login
    unless params[:username].nil? && params[:password].nil?
      self.current_user = User.authenticate(params[:username], params[:password])
      if current_user
        #if we want to redirect back to the full request
        #jumpto = session[:jumpto] || { :action => "index" }
        #@session[:jumpto] = nil
        #redirect_to(jumpto)
        
        redirect_back_or_default(:controller => 'me', :id => self.current_user)
        #flash[:notice] = _("Logged in successfully")
      else
        flash[:error] = _("Username or password is incorrect.");
      end
    end
  end
  
  def signup
    @user = User.new(params[:user])
    return unless request.post?
    if @user.save
      redirect_back_or_default(:controller => 'me', :id => self.current_user)
      flash_success _("Thanks for signing up!")
	else
	  flash_error 'user'
    end
  end
  
  def logout
    self.current_user = nil
    flash[:notice] = _("You have been logged out.")
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end

end
