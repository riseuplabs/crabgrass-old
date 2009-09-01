class AccountController < ApplicationController

  stylesheet 'account'

  before_filter :view_setup
  before_filter :setup_user_from_current, :only => :missing_info
  before_filter :setup_user, :only => :signup
  before_filter :find_or_build_profiles, :only => [:signup, :missing_info]

  skip_before_filter :redirect_unverified_user, :only => [:unverified, :login, :logout, :signup, :verify_email]
  skip_before_filter :redirect_missing_info_user, :only => [:login, :logout, :signup, :missing_info]

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

    if request.post?
      if params[:usage_agreement_accepted] != "1"
        flash_message_now :error => "Acceptance of the usage agreement is required"[:usage_agreement_required]
        raise Exception.new
      end
      # @hidden_profile
      @user.avatar = Avatar.new
      # @visible_profile.entity = @user
      # @hidden_profile.entity = @user
      # @user.profiles << @visible_profile
      # @user.profiles << @hidden_profile

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
    @user = exc.record if exc.record

    clean_up_registration_errors(@user, @visible_profile, @hidden_profile)

    flash_message_now :object => @user if @user
    flash_message_now :object => @visible_profile
    flash_message_now :object => @visible_profile.locations[0]
  end

  def missing_info
    if request.post?
      @user.email = params[:user][:email]
      @hidden_profile.email_addresses[0].email_address = @user.email

      @user.save!
      @visible_profile.save!
      @visible_profile.locations[0].save!
      @hidden_profile.save!
      redirect_to params[:redirect] || current_site.login_redirect(current_user)
    end
  rescue ActiveRecord::RecordInvalid => exc
    clean_up_registration_errors(@user, @visible_profile, @hidden_profile)
    flash_message_now :object => @user if @user
    flash_message_now :object => @visible_profile
    flash_message_now :object => @visible_profile.locations[0]
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
  def clean_up_registration_errors(user, visible_profile, hidden_profile)
    # profile errors will be in profiles
    user.errors.clear_for_attribute("profiles") if user
    # we're going to show location errors on their own
    visible_profile.errors.clear_for_attribute("locations")
    # email address is validated by the user model
    hidden_profile.errors.clear_for_attribute("email_addresses") if user
    # copy hidden profile errors to visible profile
    hidden_profile.errors.each {|attribute, msg|
      visible_profile.errors.add(attribute, msg)
    }
  end

  #def send_welcome_message(user)
  #  page = Page.make :private_message, :to => user, :from => user, :title => 'Welcome to crabgrass!', :body => :welcome_text.t
  #  page.save
  #end

  # where to go when the user logs in?
  # depends on the settings (for example, unverified users should not see any pages)
  def redirect_successful_login
    params[:redirect] = nil unless params[:redirect].any?
    if current_user.unverified?
      redirect_to :action => 'unverified'
    elsif current_user.missing_profile_info?
      redirect_to :action => 'missing_info', :redirect => params[:redirect] || current_site.login_redirect(current_user)
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

  def setup_user_from_current
    if logged_in?
      @user = current_user
    else
      raise "Not logged in."
    end
  end

  def setup_user
    @user = User.new(params[:user] || {:email => session[:signup_email_address]})
  end

  def find_or_build_profiles
    # hidden profile
    @hidden_profile = @user.profiles.hidden
    @hidden_profile.email_addresses.build(:email_address => @user.email, :email_type => "Other")
    @hidden_profile.attributes = @hidden_profile.attributes.merge(params[:hidden_profile] || {})

    # visible profile
    @visible_profile = if current_site.profile_enabled?(:public)
      @user.profiles.public
    else
      @user.profiles.private
    end

    # the location for public profile
    if params[:visible_profile] and params[:visible_profile][:locations]
      updated_location = ProfileLocation.new(params[:visible_profile][:locations].first)
      params[:visible_profile].delete(:locations)
    else
      updated_location = nil
    end

    @visible_profile.attributes = @visible_profile.attributes.merge(params[:visible_profile] || {})
    @visible_profile.locations[0] ||= ProfileLocation.new
    if updated_location
      location = @visible_profile.locations[0]
      location.attributes = updated_location.attributes
    end

    @user.setup_profile_required_info(@visible_profile, @hidden_profile)
  end

end
