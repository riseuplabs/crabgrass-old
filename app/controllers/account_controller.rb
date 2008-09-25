class AccountController < ApplicationController

  stylesheet 'account'

  def index
    if logged_in?
      redirect_to me_url
    end
  end

  def login
    return unless request.post?
    reset_session # important!!
                  # always force a new session on every login attempt
                  # in order to prevent session fixation attacks. 
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = {
          :value => self.current_user.remember_token,
          :expires => self.current_user.remember_token_expires_at
        }
      end
      redirect_to params[:redirect] || {:controller => '/me/dashboard', :action => 'index'}
    else
      flash_message :title => "Could not log in"[:login_failed],
        :error => "Username or password is incorrect."[:login_failure_reason]
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    send_welcome_message(current_user)
    redirect_to params[:redirect] || {:controller => '/account', :action => 'welcome'}
    flash_message :title => 'Registration successful'[:signup_success],
      :success => "Thanks for signing up!"[:signup_success_message]
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash_message :title => "Goodbye"[:logout_success],
      :success => "You have been logged out."[:logout_success_message]
    redirect_to :controller => '/account', :action => 'index'
  end

  def welcome
    render :text => WholeCloth.new(:welcome_text.t).to_html, :layout => 'default'
  end
  
  protected
  def send_welcome_message(user)
    page = Page.make :private_message, :to => user, :from => user, :title => 'Welcome to crabgrass!', :body => :welcome_text.t
    page.save
  end
  
end
