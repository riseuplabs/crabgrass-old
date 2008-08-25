=begin

ParticipationController
---------------------------------

This is a controller for managing participations with a page
(ie user_participations and group_participations).

=end

class BasePage::ParticipationController < ApplicationController

  before_filter :login_required
  verify :method => :post, :only => [:move]

  helper 'base_page', 'base_page/participation'

  # TODO: add non-ajax version
  # TODO: send a 'made public' message to watchers
  # Requires :admin access
  def update_public
    @page.public = ('true' == params[:public])
    @page.updated_by = current_user
    @page.save
    render :template => 'base_page/participation/reset_public_line'
  end

  # post
  def add_star
    @page.add(current_user, :star => true)
    redirect_to page_url(@page)
  end
  def remove_star
    @page.add(current_user, :star => false)
    redirect_to page_url(@page)
  end

  # xhr
  def add_watch
    @page.add(current_user, :watch => true)
    @upart = @page.participation_for_user(current_user)
    render :template => 'base_page/participation/reset_watch_line'
  end
  def remove_watch
    @page.add(current_user, :watch => false)
    @upart = @page.participation_for_user(current_user)
    render :template => 'base_page/participation/reset_watch_line'
  end

  def show_popup
    render :template => 'base_page/participation/show_' + params[:name] + '_popup'
  end

  # alter the group_participations so that the primary group is
  # different.
  # requires :admin access
  def move
    if params[:cancel]
      redirect_to page_url(@page)
    elsif params[:group_id].any?
      group = Group.find params[:group_id]
      @page.remove(@page.group) if @page.group
      @page.add(group, :access => :admin)
      @page.group = group
      current_user.updated(@page)
      @page.save
      clear_referer(@page)
      redirect_to page_url(@page)      
    end
  end
  
  ##
  ## PAGE SHARING
  ## 

  # share this page with a notice message to any number of recipients. 
  #
  # if the recipient is a user name, then the message and the page show up in
  # user's inbox, and optionally they are alerted via email.
  #
  # if the recipient is an email address, an email is sent to the address with a
  # magic url that lets the recipient view the page by clicking on a link
  # and using their email as the password.
  # 
  # the sending user must have admin access to send to recipients
  # who do not already have the ability to view the page.
  # 
  # the recipient may be an entire group, in which case we grant access
  # to the group and send emails to each user in the group.
  #
  # you cannot share to users/groups that you cannot pester, unless
  # the page is private and they already have access.
  #
  def share
    if params[:cancel]
      close_popup and return
    end
    begin
      users, groups, emails = parse_recipients!(params[:recipients])

      access = params[:access].any? ? params[:access].to_sym : nil
      msg = params[:message]
      users_to_email = []

      ## add users to page
      users.each do |user|
        if current_user.share_page_with_user!(@page, user, :access => access, :message => msg)
          users_to_email << user if user.wants_notification_email?
        end
      end

      ## add groups to page
      groups.each do |group|
        users_succeeded = current_user.share_page_with_group!(@page, group,
          :access => access, :message => msg)
        users_succeeded.each do |user|
          users_to_email << user if user.wants_notification_email?
        end
      end

      ## send access granted emails (TODO)
      # emails.each do |email|
      #   Mailer.deliver_page_notice_with_url_access(email, msg, mailer_options)
      # end

      ## send notification emails
      if params[:send_emails]
        users_to_email.each do |user|
          logger.info '----------------- emailing %s' % user.email
          Mailer.deliver_page_notice(user, msg, mailer_options)
        end
      end

      # success!!
      @page.save
      close_popup

    rescue PermissionDenied => exc
      flash_message_now :title => 'Permission Denied'[:permission_denied], :error => exc
      show_error_message
    rescue ErrorMessages => exc
      flash_message_now :title => exc.title, :error => exc.errors
      show_error_message
    rescue Exception => exc
      flash_message_now :title => 'Error: ' + exc.class.to_s, :error => exc.to_s
      show_error_message
    end
  end

  ##
  ## PAGE DETAILS
  ## participation and access
  ##

  def close_details
    close_popup
  end

  # create or update a user_participation object, granting new access. 
  def create
    begin
      users, groups, emails = parse_recipients!(params[:add_names])
      (users+groups).each do |thing|
        @page.add(thing, :access => params[:access].to_sym)
      end
      render :update do |page|
        page.replace_html 'permissions_tab', :partial => 'base_page/participation/permissions'
      end
    rescue ErrorMessages => exc
      flash_message_now :title => exc.title, :error => exc.errors
      show_error_message
    rescue Exception => exc
      flash_message_now :title => 'Error: ' + exc.class.to_s, :error => exc.to_s
      show_error_message
    end
  end
  
  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access. 
  def destroy
    @upart = UserParticipation.find params[:upart_id] if params[:upart_id]
    if @upart and @upart.user_id != @page.created_by_id
      @upart.destroy
    end

    @gpart = GroupParticipation.find params[:gpart_id] if params[:gpart_id]
    if @gpart and @gpart.group_id != @page.group_id
      @gpart.destroy
    end

    render :update do |page|
      page.hide dom_id(@upart || @gpart)
    end
  end

  
  protected
  
  def close_popup
    render :template => 'base_page/reset_sidebar'
  end

  def show_error_message
    render :template => 'base_page/show_errors'
  end

  # called by share()
  # parses a list of recipients, turning them into email, user, or group
  # objects as appropriate.
  def parse_recipients!(recipients)
    users = []; groups = []; emails = []; errors = []
    if recipients.is_a? Hash
      to = []
      recipients.each do |key,value|
        to << key if value == '1'
      end
    elsif recipients.is_a? Array
      to = recipients
    elsif recipients.is_a? String
      to = recipients.split(/[\s,]/)
    end
    to.each do |entity|
      if entity =~ RFC822::EmailAddress
        emails << entity
      elsif g = Group.get_by_name(entity)
        groups << g
      elsif u = User.find_by_login(entity)
        users << u
      elsif entity.any?
        errors << '"%s" does not match the name of any users or groups and is not a valid email address' % entity
      end
    end

    unless errors.empty?
      raise ErrorMessages.new('Could not understand some recipients.', errors)
    end

    [users, groups, emails]
  end


  def authorized?
    if ['update_public', 'move', 'create','destroy'].include? params[:action]
      current_user.may? :admin, @page
    else
      current_user.may? :view, @page
    end
  end
  
  prepend_before_filter :fetch_page
  def fetch_page
    if params[:id]
      # not yet used:
      #@upart = UserParticipation.find_by_id(params[:id])
      #@page = @upart.page
    elsif params[:page_id]
      @page = Page.find_by_id(params[:page_id])
      @upart = @page.participation_for_user(current_user)
    end
    true
  end
  
end
