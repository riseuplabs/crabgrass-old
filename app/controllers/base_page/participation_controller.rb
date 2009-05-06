=begin

ParticipationController
---------------------------------

This is a controller for managing participations with a page
(ie user_participations and group_participations).

=end

class BasePage::ParticipationController < ApplicationController

  verify :method => :post, :only => [:move]

  helper 'base_page', 'base_page/participation'
  
  include BasePageHelper
  
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
    @page.add(current_user, :star => true).save!
    redirect_to page_url(@page)
  end
  def remove_star
    @page.add(current_user, :star => false).save!
    redirect_to page_url(@page)
  end

  # xhr
  def add_watch
    @upart = @page.add(current_user, :watch => true)
    @upart.save!
    render :template => 'base_page/participation/reset_watch_line'
  end
  
  def remove_watch
    @upart = @page.add(current_user, :watch => false)
    @upart.save!
    render :template => 'base_page/participation/reset_watch_line'
  end

  def show_popup
    render :template => 'base_page/participation/show_' + params[:name] + '_popup'
  end

  # moves this page to a new group.
  # requires :admin access.
  def move
    if params[:cancel]
      redirect_to page_url(@page)
    elsif params[:group_id].any?
      group = Group.find params[:group_id]
      raise PermissionDenied.new unless current_user.member_of?(group)
      @page.remove(@page.group) if @page.group
      @page.owner = group
      current_user.updated(@page)
      @page.save!
      clear_referer(@page)
      redirect_to page_url(@page)      
    end
  end

  # this is very similar to move.
  # only allow changing the owner to someone who is already an admin
  def set_owner
    if params[:owner].any?
      owner = (User.find_by_login(params[:owner]) || Group.find_by_name(params[:owner]))
      raise PermissionDenied.new unless owner.may?(:admin,@page)
      @page.owner = owner
      @page.save!
    end
    clear_referer(@page)
    redirect_to page_url(@page)
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
      users, groups, emails = Page.parse_recipients!(params[:add_names])
      (users+groups).each do |thing|
        @page.add(thing, :access => params[:access].to_sym).save!
      end
      @page.save!
      render :update do |page|
        page.replace_html 'permissions_tab', :partial => 'base_page/participation/permissions'
      end
    rescue Exception => exc
      flash_message_now :exception => exc
      show_error_message
    end
  end

  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access. 
  def destroy
    upart = (UserParticipation.find(params[:upart_id]) if params[:upart_id])
    if upart and upart.user_id != @page.created_by_id
      @page.remove(upart.user) # this is the only way users should be removed.
      @page.save!
    end

    gpart = (GroupParticipation.find(params[:gpart_id]) if params[:gpart_id])
    if gpart and gpart.group_id != @page.group_id
      @page.remove(gpart.group) # this is the only way groups should be removed.
      @page.save!
    end

    render :update do |page|
      page.hide dom_id(upart || gpart)
    end
  end

  protected

  ##
  ## UI METHODS FOR THE SHARE & NOTIFY FORMS
  ## 

  # given the params[:recipients] returns an options-hash for recipients
  def get_recipients_with_options(recipients_with_options)  
    options_with_recipients = {}
    recipients_with_options.each_pair do |recipient,options|
      if options.kind_of?(Hash)
        options_with_recipients[symbolize_options(options)] ||= []
        options_with_recipients[symbolize_options(options)] << recipient.sub(" ", "+")
      end
      @recipients ||= []
      @recipients << recipient
    end
    options_with_recipients   
  end

  
  def symbolize_options options
    return options unless options.respond_to?(:each)
    symbolized_options = {}
    options.each do |k,v|
      k.respond_to?(:to_sym) ? k = k.to_sym : k ;
      v.respond_to?(:to_sym) ? v = v.to_sym : v ;
      symbolized_options[k] = v
    end
    symbolized_options
  end

  def close_popup
    render :template => 'base_page/reset_sidebar'
  end

  def show_error_message
    render :template => 'base_page/show_errors'
  end

  def authorized?
    if action?('update_public','create','destroy', 'move','set_owner')
      current_user.may? :admin, @page
    else
      current_user.may? :view, @page
    end
  end

  prepend_before_filter :fetch_page
  def fetch_page
    if params[:page_id]
      @page = Page.find_by_id(params[:page_id])
      @upart = @page.participation_for_user(current_user)
    end
    true
  end

end
