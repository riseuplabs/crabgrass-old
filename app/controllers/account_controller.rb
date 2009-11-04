class AccountController < ApplicationController

  stylesheet 'account'

  before_filter :view_setup

  skip_before_filter :redirect_unverified_user, :only => [:unverified, :login, :logout, :signup, :verify_email]

  # TODO: it would be good to require post for logout in the future
  verify :method => :post, :only => [:language]

  def index
    if logged_in?
      redirect_to me_url
    end
  end

  def login
    if !( params[:redirect].empty? || params[:redirect] =~ /^https?:\/\/#{request.domain}/ || params[:redirect] =~ /^\//)
      flash_message(:title => 'Illegal redirect'[:illegal_redirect],
      :error => "You are trying to redirect to a foreign domain {url} after your login. For security reasons we have removed this parameter from the URL."[:redirect_to_foreign_domain, {:url => params.delete(:redirect)}])
      redirect_to params and return
    end
    return unless request.post?
    previous_language = session[:language_code]

    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      reset_session # important!!
                    # always force a new session on every login success
                    # in order to prevent session fixation attacks.
      # have to reauth, since we cleared the session
      self.current_user = User.authenticate(params[:login], params[:password])

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

      current_site.add_user!(current_user)
      UnreadActivity.create(:user => current_user)
      redirect_successful_login
    else
      flash_message_now :title => "Could not log in"[:login_failed],
      :error => "Username or password is incorrect."[:login_failure_reason]
    end

  end

  def signup
    if current_site.signup_redirect_url.any?
      redirect_to current_site.signup_redirect_url
    elsif !may_signup?
      raise PermissionDenied.new('new user registration is closed at this time')
    end

    @user = User.new(params[:user] || {:email => session[:signup_email_address]})

    if request.post?
      if params[:usage_agreement_accepted] != "1"
        raise ErrorMessage.new("Acceptance of the usage agreement is required"[:usage_agreement_required])
      end

      @user.avatar = Avatar.new
      @user.unverified = current_site.needs_email_verification?
      @user.save!
      session[:signup_email_address] = nil
      self.current_user = @user
      current_site.add_user!(current_user)

      send_email_verification if current_site.needs_email_verification?

      redirect_to params[:redirect] || current_site.login_redirect(current_user)
      flash_message :title => 'Registration successful'[:signup_success],
        :success => "Thanks for signing up!"[:signup_success_message]
    end
  rescue Exception => exc
    @user = exc.record
    flash_message_now :exception => exc
    render :action => 'signup'
  end


  # verify the users email
  def verify_email
    @token = Token.find_by_value_and_action(params[:token], 'verify')
    @token.destroy if @token
    if @token.nil? or @token.user.nil? or !@token.user.unverified?
      flash_message :title => "Already Verified."[:already_verified], :success => "You don't need to verify again."[:already_verified_text]
    else
      @token.user.update_attribute(:unverified, false)
      flash_message :title => 'Successfully Verified Email Address'[:successfully_verified_email_message],
        :success => "Thanks for signing up!"[:signup_success_message]
    end

    redirect_to '/'
  end

  def unverified
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

  # where to go when the user logs in?
  # depends on the settings (for example, unverified users should not see any pages)
  def redirect_successful_login
    params[:redirect] = nil unless params[:redirect].any?
    if current_user.unverified?
      redirect_to :action => 'unverified'
    else
      redirect_to(params[:redirect] || current_site.login_redirect(current_user))
    end
  end

  def send_email_verification
    @token = Token.create!(:user => current_user, :action => 'verify')
    Mailer.deliver_email_verification(@token, mailer_options)
  end

  def view_setup
    @active_tab = :home
  end

end
