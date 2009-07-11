=begin

ParticipationController
---------------------------------

This is a controller for managing participations with a page
(ie user_participations and group_participations).

=end

class BasePage::ParticipationController < ApplicationController

  before_filter :login_required
  verify :method => :post, :only => [:move, :set_owner]
  helper 'base_page', 'base_page/participation'
  permissions 'base_page'

  ##
  ## Participation CRUD
  ##

  # create or update a user_participation object, granting new access. 
  def create
    begin
      users, groups, emails = Page.parse_recipients!(params[:add_names])
      (users+groups).each do |thing|
        @page.add(thing, :access => (params[:access]||'view')).save!
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
    error = "The access to this page could not be removed. You cannot remove the owners access or an access that is necessary for you to administrate the page."[:remove_access_error]
    upart = (UserParticipation.find(params[:upart_id]) if params[:upart_id])
    gpart = (GroupParticipation.find(params[:gpart_id]) if params[:gpart_id])
    if may_remove_participation?(upart)
      @page.remove(upart.user)
    elsif may_remove_participation?(gpart)
      @page.remove(gpart.group)
    else
      raise ErrorMessage.new(error)
    end

    render :update do |page|
      page.hide dom_id(upart || gpart)
    end
  rescue Exception => exc
    flash_message_now :exception => exc
    show_error_message
  end
  
  def show
     if params[:popup]
       render :partial => 'base_page/participation/' + params[:name] + '_popup'
     elsif params[:cancel]
       close_popup
     end
  end

  ##
  ## PARTICIPATION UPDATES
  ##

  def update_public
    @page.public = params[:add]
    @page.updated_by = current_user
    @page.save
    render :template => 'base_page/participation/reset_public_line'
  end

  def update_star
    @upart = @page.add(current_user, :star => params[:add])
    @upart.save!
    @page.reload
    render :template => 'base_page/participation/reset_star_line'
  end

  after_filter :track_starring, :only => :update_star
  def track_starring
    action = params[:add] ? :star : :unstar
    if current_site.tracking
      Tracking.insert_delayed(:page => @page,
                              :group => @group,
                              :user => current_user,
                              :action => action)
    elsif
      Tracking.insert_delayed(:page => @page,
                              :action => action)
    end
  end

  def update_watch
    @upart = @page.add(current_user, :watch => params[:add])
    @upart.save!
    render :template => 'base_page/participation/reset_watch_line'
  end

  ##
  ## CHANGING OWNER
  ## hmm... this is not technically part of the participation
  ##

  # moves this page to a new group.
  def move
    if params[:cancel]
      close_popup
    elsif params[:group_id].any?
      group = if params[:group_id].match(/^\d+$/)
                Group.find params[:group_id]
              else
                Group.find_by_name params[:group_id]
              end
      raise PermissionDenied.new unless current_user.member_of?(group)
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
      owner = (User.on(current_site).find_by_login(params[:owner]) || Group.find_by_name(params[:owner]))
      raise PermissionDenied.new unless owner.may?(:admin,@page)
      @page.owner = owner
    else
      @page.owner = nil
    end
    @page.save!
    clear_referer(@page)
    redirect_to page_url(@page)
  end
    
  protected

  def authorized?
    if action?(:move, :set_owner)
      may_move_page?
    elsif action?(:update_public)
      may_public_page?
    elsif action?(:update_star)
      may_star_page?
    elsif action?(:update_watch)
      may_watch_page?
    else
      may_action?
    end
  end

  # given the params[:recipients] returns an options-hash for recipients
#  def get_recipients_with_options(recipients_with_options)  
#    options_with_recipients = {}
#    recipients_with_options.each_pair do |recipient,options|
#      if options.kind_of?(Hash)
#        options_with_recipients[symbolize_options(options)] ||= []
#        options_with_recipients[symbolize_options(options)] << recipient.sub(" ", "+")
#      end
#      @recipients ||= []
#      @recipients << recipient
#    end
#    options_with_recipients   
#  end

#  
#  def symbolize_options options
#    return options unless options.respond_to?(:each)
#    symbolized_options = {}
#    options.each do |k,v|
#      k.respond_to?(:to_sym) ? k = k.to_sym : k ;
#      v.respond_to?(:to_sym) ? v = v.to_sym : v ;
#      symbolized_options[k] = v
#    end
#    symbolized_options
#  end

  def close_popup
    render :template => 'base_page/reset_sidebar'
  end

  def show_error_message
    render :template => 'base_page/show_errors'
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
