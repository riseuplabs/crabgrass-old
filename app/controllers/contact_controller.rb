#
# a controller for managing contacts
# currently, this only manages friendships
#

class ContactController < ApplicationController

  permissions 'contact'
  before_filter :login_required

  def add
    if current_user.friend_of?(@user)
      redirect_to :action => 'already_friends', :id => @user
    elsif @past_request.any?
      redirect_to :action => 'approve', :id => @user
    elsif request.post? and params[:cancel]
      redirect_to url_for_user(@user)
    elsif request.post? and params[:send]
      begin
        RequestToFriend.create! :created_by => current_user, :recipient => @user
        flash_message_now :success => I18n.t(:contact_request_sent)
      rescue Exception => exc
        flash_message_now :exception => exc
      end
    end
  end

  def approve
    redirect_to :action => 'already_friends', :id => @user if current_user.friend_of?(@user)
  end

  def already_friends
  end

  def remove
    unless current_user.friend_of?(@user)
      flash_message_now :error => I18n.t(:not_contact_of, :user => @user.name)
      return
    end

    if request.post? and params[:cancel]
      redirect_to url_for_user(@user)
    elsif request.post? and params[:remove]
      current_user.remove_contact!(@user)
      flash_message_now :success => I18n.t(:contact_removed, :user => @user.login)
    end
  end

  protected

  prepend_before_filter :fetch_user
  def fetch_user
    @user = User.find_by_login params[:id] if params[:id]
    @past_request = RequestToFriend.created_by(@user).to_user(current_user).appearing_as_state('pending')
    true
  end

  def context
    person_context
    add_context 'contact', url_for(:controller => 'contact', :action => 'add', :id => @user)
  end

end
