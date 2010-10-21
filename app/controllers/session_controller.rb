class SessionController < ApplicationController

  # stylesheet 'account'
  layout 'notice'

  skip_before_filter :redirect_unverified_user
  before_filter :stop_illegal_redirect, :only => [:login]
  verify :method => :post, :only => [:language, :logout]

  def login
    return unless request.post?
    previous_language = session[:language_code]
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      reset_session # important!!
                    # always force a new session on every login success
                    # in order to prevent session fixation attacks.
      # have to reauth, since we just cleared the session
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
      flash_message_now :title => I18n.t(:login_failed),
      :error => I18n.t(:login_failure_reason)
    end

  end

  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    language = session[:language_code]
    reset_session
    session[:language_code] = language
    flash_message :title => I18n.t(:logout_success),
      :success => I18n.t(:logout_success_message)
    redirect_to '/'
  end

  # set the language of the current session
  def language
    session[:language_code] = params[:id].to_sym
    redirect_to referer
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

  # before filter
  def stop_illegal_redirect
    unless params[:redirect].empty? || params[:redirect] =~ /^https?:\/\/#{request.domain}/ || params[:redirect] =~ /^\//
      flash_message(:title => I18n.t(:illegal_redirect),
      :error => I18n.t(:redirect_to_foreign_domain, :url => params.delete(:redirect)))
      redirect_to params
      false
    else
      true
    end
  end

end
