class AccountController < ApplicationController

  stylesheet 'account'
  javascript 'account', :action => :signup

  skip_before_filter :verify_authenticity_token, :only => :login

  # TODO: it would be good to require post for logout in the future
  verify :method => :post, :only => [:language]
   
  def index
    if logged_in?
      redirect_to me_url
    end
  end

  def login
    if !( params[:redirect].empty? || params[:redirect] =~ /^http:\/\/#{request.domain}/ || params[:redirect] =~ /^\//)
      flash_message(:title => 'Illegal redirect'[:illegal_redirect],
      :error => "You are trying to redirect to a foreign domain (:url) after your login. For security reasons we have removed this parameter from the URL."[:redirect_to_foreign_domain]%{ :url => params.delete(:redirect)})
      redirect_to params and return
    end
    return unless request.post?
    previous_language = session[:language_code]
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

      if self.current_user.language.any?
        session[:language_code] = self.current_user.language.to_sym
      else
        session[:language_code] = previous_language
      end
      redirect_to params[:redirect] || {:controller => '/me/dashboard', :action => 'index'}
    else
      flash_message :title => "Could not log in"[:login_failed],
        :error => "Username or password is incorrect."[:login_failure_reason]
    end
  end

  def signup
    @user = User.new(params[:user] || {:email => session[:signup_email_address]})
    return unless request.post?

    if params[:usage_agreement_accepted] != "1"
      flash_message_now :error => "Acceptance of the usage agreement is required"[:usage_agreement_required]
      return
    end

    @user.avatar = Avatar.new
    @user.save!
    session[:signup_email_address] = nil
    self.current_user = @user
    send_welcome_message(current_user)
    redirect_to params[:redirect] || {:controller => '/account', :action => 'welcome'}
    flash_message :title => 'Registration successful'[:signup_success],
      :success => "Thanks for signing up!"[:signup_success_message]
  rescue Exception => exc
    @user = exc.record
    flash_message_now :exception => exc
    render :action => 'signup'
  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    language = session[:language_code]
    reset_session
    session[:language_code] = language
    flash_message :title => "Goodbye"[:logout_success],
      :success => "You have been logged out."[:logout_success_message]
    redirect_to :controller => '/account', :action => 'index'
  end

  # set the language of the current session
  def language
    session[:language_code] = params[:id].to_sym
    redirect_to referer
  end

  def welcome
    render :text => GreenCloth.new(:welcome_text.t).to_html, :layout => 'default'
  end

  def forgot_password
    return unless request.post?

    unless RFC822::EmailAddress.match(params[:email])
      flash_message_now :title => "Invalid Email"[:invalid_email],
        :error => "The email address you provided is invalid."[:invalid_email_text]
      render and return
    end

    user = User.find_for_forget(params[:email])

    # it's an information leak to tell the user that the email address couldn't be found . . .
    if user
      token = Token.new(:user => user, :action => "recovery")
      token.save
      Mailer.deliver_forgot_password(token, mailer_options)
    end

    flash_message :title => "Reset Password"[:reset_password],
      :success => "An email has been sent containing instructions for resetting your password."[:reset_password_email_sent]
    redirect_to :action => 'index'
  end
  
  def reset_password
    @token = Token.find_by_value_and_action(params[:token], 'recovery')
    unless @token && !@token.expired?
      flash_message :title => "Invalid Token"[:invalid_token],
        :error => "The password reset link you specified is invalid. Presumably it has already been used, or it has expired."[:invalid_token_text]
      redirect_to :action => 'index' and return
    end
    
    @user = @token.user
    return unless request.post?
    
    @user.password = params[:new_password]
    @user.password_confirmation = params[:password_confirmation]
    if @user.save
      Mailer.deliver_reset_password(@user, mailer_options)
      @token.destroy
      flash_message :title => "Password Reset"[:password_reset],
        :success => "Your password has been successfully reset. You can now log in with your newly changed password."[:password_reset_ok_text]
      redirect_to :action => 'index'
    else
      flash_message_now :object => @user
    end
  end
  
  protected
  def send_welcome_message(user)
    page = Page.make :private_message, :to => user, :from => user, :title => 'Welcome to crabgrass!', :body => :welcome_text.t
    page.save
  end
  
end
