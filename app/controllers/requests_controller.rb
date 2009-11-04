#
# Requests Controller.
#
# For code specific to group requests, see groups/requests_controller.rb
#
# For code specific to me requests, see me/requests_controller.rb
#
class RequestsController < ApplicationController

  permissions 'requests'
  verify :method => :post, :except => [:accept, :redeem]
  prepend_before_filter :set_language_from_invite, :only => [:accept]
  before_filter :fetch_data
  before_filter :login_required, :except => [:accept]

  ##
  ## approval
  ##

  def reject
    begin
      @request.reject_by!(current_user)
    rescue Exception => exc
      flash_message :exception => exc
    end
    redirect_to referer
  end

  def approve
    begin
      @request.approve_by!(current_user)
    rescue Exception => exc
      flash_message :exception => exc
    end

    unless referer =~ /\/approve/ # don't redirect to the approve action
      redirect_to referer
    else
      redirect_to url_for_user(@request.created_by)
    end
  end

  def ignore
    # begin
    #   @request.ignore_by!(current_user)
    # rescue Exception => exc
    #   flash_message :exception => exc
    # end
    redirect_to referer
  end

  def destroy
    begin
      @request.destroy
    rescue Exception => exc
      flash_message :exception => exc
    end
    redirect_to referer
  end

#  ##
#  ## approval by ajax
#  ##

#  def reject
#    @request.reject_by!(current_user)
#    render :update {|page| page.hide(@request.dom_id)}
#  rescue Exception => exc
#    flash_message_now :exception => exc
#  end

#  def approve
#    @request.approve_by!(current_user)
#    render :update {|page| page.hide(@request.dom_id)}
#  rescue Exception => exc
#    flash_message_now :exception => exc
#  end

#  def destroy
#    @request.destroy
#    render :update {|page| page.hide(@request.dom_id)}
#  rescue Exception => exc
#    flash_message_now :exception => exc
#  end

  ##
  ## email responses
  ##

  def accept
    # redeem_url must be *relative*
    redeem_url = url_for(:only_path => true, :controller => 'requests', :action => 'redeem', :email => @email, :code => @code)

    if @request
      if @request.state != 'pending'
        raise_error I18n.t(:invite_error_redeemed)
      elsif logged_in?
        redirect_to redeem_url
      else
        session[:signup_email_address] = @email
        session[:user_has_accepted_invite] = true
        @login_url = url_for({
          :controller => 'account', :action => 'login',
          :redirect => redeem_url
        })
        @register_url = url_for({
          :controller => 'account', :action => 'signup',
          :redirect => redeem_url
        })
      end
    else
      raise_not_found I18n.t(:invite)
    end
  rescue Exception => exc
    render_error(exc)
  end

  # redeem the invite after first login or register
  def redeem
    email = params[:email]
    code  = params[:code]
    request = RequestToJoinUsViaEmail.redeem_code!(current_user, code, email)
    request.approve_by!(current_user)
    flash_message :success => I18n.t(:join_group_success, :group_name => request.group.name)
    redirect_to current_site.login_redirect(current_user)
  rescue Exception => exc
    render_error(exc)
  end

  protected

  def fetch_data
    @request = Request.find_by_id(params[:id]) if params[:id]
  end

  def set_language_from_invite
    @code = params[:path][0]
    @email = params[:path][1].gsub('_at_','@')
    @request = RequestToJoinUsViaEmail.find_by_code_and_email(@code,@email)
    session[:language_code] ||= @request.language unless @request.nil?
  end

end
