#
# Requests Controller.
# 

class RequestsController < ApplicationController

  helper 'group', 'application'
  stylesheet 'groups'

  prepend_before_filter :set_language_from_invite, :only => [:accept]
  before_filter :login_required, :except => [:accept]
 
  def list
    if @group
      params[:state] ||= 'pending'
      @incoming = Request.to_group(@group).having_state(params[:state]).by_created_at.paginate(:page => params[:in_page])

      @outgoing = Request.from_group(@group).appearing_as_state(params[:state]).by_created_at.paginate(:page => params[:out_page])
      # hide ignored states
      @outgoing.each {|r| r.state = 'pending'} if params[:state] == 'pending'
    end
  end

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

  ##
  ## CREATION
  ## 

=begin  
  def create_contact
    if request.get?
      store_back_url and return
    else
      redirect_to_back_url and return unless params[:send]
    end

    begin
      RequestToFriend.create! :created_by => current_user, :recipient => @user
      flash_message :success => 'Contact request has been sent'
      redirect_to_back_url
    rescue Exception => exc
      flash_message_now :exception => exc
    end   
  end
=end

  def create_join
    if request.get?
      store_back_url and return
    else
      redirect_to url_for_group(@group) and return unless params[:send]
    end

    begin
      RequestToJoinYou.create! :created_by => current_user, :recipient => @group
      flash_message_now :success => 'Request to join has been sent'.t
    rescue Exception => exc
      flash_message_now :exception => exc
    end
  end

  def create_invite
    if request.get?
      store_back_url and return
    else
      redirect_to url_for_group(@group) unless params[:send]
    end

    begin
      users, groups, emails = Page.parse_recipients!(params[:recipients])
      groups = [] unless @group.network?

      reqs = []; mailers = []
      unless users.any? or emails.any? or groups.any?
        raise ErrorMessage.new('recipient required'.t)
      end
      users.each do |user|
        if params[:email_all]
          emails << user.email     
        else
          reqs << RequestToJoinUs.create(:created_by => current_user,
            :recipient => user, :requestable => @group)
        end
      end
      groups.each do |group|
        reqs << RequestToJoinOurNetwork.create(:created_by=>current_user,
          :recipient => group, :requestable => @group)
      end
      emails.each do |email|
        req = RequestToJoinUsViaEmail.create(:created_by => current_user,
          :email => email, :requestable => @group, :language => Gibberish.current_language.to_s)
        begin
          Mailer.deliver_request_to_join_us!(req, mailer_options)
          reqs << req
        rescue Exception => exc
          flash_message_now :text => "#{'Could not deliver email'.t} (#{email}):", :exception => exc
          req.destroy
        end
      end
      if reqs.detect{|req|!req.valid?}
        reqs.each do |req|
          if req.valid?
            flash_message_now :title => 'Error'.t,
              :text => "Success".t + ':',
              :success => 'Invitation sent to %s'[:invite_sent] % req.recipient.display_name
          else
            flash_message_now :title => 'Error'.t, :object => req
          end
        end
      else
        flash_message_now :success => '%d invitations sent'[:invites_sent] % reqs.size
        params[:recipients] = ""
      end
    rescue Exception => exc
      flash_message_now :exception => exc
    end
  end

  ##
  ## email responses
  ##
  
  def accept
    redeem_url = url_for(:controller => 'requests', :action => 'redeem',
     :email => @email, :code => @code) 

    if @request
      if @request.state != 'pending'
        @error = "Invite has already been redeemed"[:invite_redeemed]
      elsif logged_in?
        redirect_to redeem_url
      else
        session[:signup_email_address] = @email
        @login_url = url_for({
          :controller => 'account', :action => 'login',
          :redirect => redeem_url
        })
        @register_url = url_for({
          :controller => 'account', :action => 'signup',
          :redirect => redeem_url
        })
      end
    end

    rescue Exception => exc
      flash_message_now :exception => exc
  end

  # redeem the invite after first login or register
  def redeem
    email = params[:email]
    code  = params[:code]
    request = RequestToJoinUsViaEmail.redeem_code!(current_user, code, email)
    request.approve_by!(current_user)
    flash_message :success => 'You have joined group {group_name}'[:join_group_success, {:group_name => request.group.name}]
    if current_user.created_at > 1.minutes.ago
      redirect_to :controller => 'account', :action => 'welcome'
    else
      redirect_to '/me/dashboard'
    end
    rescue Exception => exc
      flash_message_now :exception => exc    
  end

  protected
    
  def context
    if @group
      group_context
      add_context 'membership', url_for(:controller=>'membership', :action => 'list', :id => @group)
    elsif @user
      user_context
    end
  end
  
  prepend_before_filter :fetch_data
  def fetch_data
    @group = Group.find(params[:group_id]) if params[:group_id]
    @user  = User.find(params[:user_id]) if params[:user_id]
    @request = Request.find(params[:id]) if params[:id]
  end
  
  before_filter :setup_sidebar
  def setup_sidebar
    if @group
      @left_column = render_to_string :partial => 'membership/sidebar'
    elsif @user
      @left_column = render_to_string :partial => 'person/sidebar'
    end
  end

  def set_language_from_invite
    @code = params[:path][0]
    @email = params[:path][1].gsub('_at_','@')
    @request = RequestToJoinUsViaEmail.find_by_code_and_email(@code,@email)
    session[:language_code] ||= @request.language unless @request.nil?
  end
  
  def authorized?
    return false unless logged_in?

    if action?(:create_join) and @group
      @group.profiles.visible_by(current_user).may_request_membership?
    elsif action?(:create_invite) and @group
      current_user.may?(:admin, @group);
    elsif action?(:list) and @group
      current_user.may?(:admin, @group);
    elsif action?(:approve, :reject) and @request
      @request.may_approve?(current_user)
    elsif action?(:destroy) and @request
      @request.may_destroy?(current_user)
    elsif action?(:redeem)
      true
    else #this should be true, otherwise prevents mods from adding actions
      true
    end
  end
  
end
