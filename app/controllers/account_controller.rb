class AccountController < ApplicationController

  stylesheet 'account'

  before_filter :view_setup
  before_filter :setup_profiles, :only => :signup
  skip_before_filter :verify_authenticity_token, :only => :login

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

      current_site.add_user!(current_user)
      UnreadActivity.create(:user => current_user)

      params[:redirect] = nil unless params[:redirect].any?
      redirect_to(params[:redirect] || current_site.login_redirect(current_user))
    else
      flash_message :title => "Could not log in"[:login_failed],
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
    @hidden_profile.email_addresses.build(:email_address => @user.email, :email_type => "Other")
    # require 'ruby-debug';debugger;1-1

    if request.post?
      if params[:usage_agreement_accepted] != "1"
        flash_message_now :error => "Acceptance of the usage agreement is required"[:usage_agreement_required]
        raise ErrorMessage.new
      end
      # @hidden_profile
      @user.avatar = Avatar.new
      # @visible_profile.entity = @user
      # @hidden_profile.entity = @user
      @user.profiles << @visible_profile
      @user.profiles << @hidden_profile

      @user.save!
      session[:signup_email_address] = nil
      self.current_user = @user
      current_site.add_user!(current_user)

      redirect_to params[:redirect] || current_site.login_redirect(current_user)
      flash_message :title => 'Registration successful'[:signup_success],
        :success => "Thanks for signing up!"[:signup_success_message]
    end
  rescue Exception => exc
    @user = exc.record if exc.record
    # massage the errors a bit
    @hidden_profile.errors.each {|attribute, msg|
      if attribute == "email_address"
        @user.errors.add('email', msg)
      else
        @visible_profile.errors.add(attribute, msg)
      end
      }

    @user.errors.clear_for_attribute("profiles")
    flash_message_now :object => @user
    flash_message_now :object => @visible_profile

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
  #def send_welcome_message(user)
  #  page = Page.make :private_message, :to => user, :from => user, :title => 'Welcome to crabgrass!', :body => :welcome_text.t
  #  page.save
  #end

  def view_setup
    @active_tab = :home
  end

  def setup_profiles
    if params[:visible_profile] and params[:visible_profile][:locations]
      visible_profile_location = ProfileLocation.create(params[:visible_profile][:locations].first)
      params[:visible_profile].delete(:locations)
    end
    @visible_profile = Profile.new(params[:visible_profile] || {})
    @visible_profile.locations << visible_profile_location if visible_profile_location
    @visible_profile.required_fields = [:first_name, :last_name, :organization, {:locations => [:city, :country_name]}]
    if current_site.profile_enabled?(:public)
      @visible_profile.stranger = true
    else
      @visible_profile.friend = true
    end
    @hidden_profile = Profile.new(params[:hidden_profile] || {})
    @hidden_profile.required_fields = [:birthday, {:email_addresses => :email_address}]
    # require 'ruby-debug';debugger;1-1
  end
end
