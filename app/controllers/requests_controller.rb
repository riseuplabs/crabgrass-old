#
# Requests Controller.
# 

class RequestsController < ApplicationController

  #stylesheet 'groups'
  helper 'groups', 'application'
    
  before_filter :login_required
 
  def list
    if @group
      @incoming = Request.to_group(@group).having_state('pending').by_created_at.paginate(:page => params[:page])
      @outgoing = Request.from_group(@group).having_state('pending').by_created_at.paginate(:page => params[:page])
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
      users, groups, email = Page.parse_recipients!(params[:recipients])
      reqs = []
      unless users.any?
        raise ErrorMessage.new('recipient required'.t)
      end
      users.each do |user|
        reqs << RequestToJoinUs.create(:created_by => current_user,
          :recipient => user, :requestable => @group)
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
        flash_message :success => '%d invitations sent'[:invites_sent] % reqs.size
        params[:recipients] = ""
      end
    rescue Exception => exc
      flash_message_now :exception => exc
    end
  end
  
  protected
    
  def context
    if @group
      group_context
      add_context 'membership', url_for(:controller=>'membership', :action => 'list', :id => @group)
    elsif @user
      user_context
    else
      me_context
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
    else
      false
    end
  end
  
end
