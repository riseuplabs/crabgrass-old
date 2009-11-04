=begin

ParticipationController
---------------------------------

This is a controller for managing participations with a page
(ie user_participations and group_participations).

=end

class BasePage::ParticipationController < BasePage::SidebarController

  before_filter :login_required
  verify :method => :post, :only => [:move, :set_owner]
  helper 'base_page/participation', 'base_page/share', 'autocomplete'

  ##
  ## Participation CRUD
  ##

  # this is used for ajax pagination
  def index
    tab = params[:tab] == 'permissions' ? 'permissions_tab' : 'participation_tab'
    render :update do |page|
      if params[:tab] == 'permissions'
        page.replace_html 'permissions_tab', :partial => 'base_page/participation/permissions'
      elsif params[:tab] == 'participation'
        page.replace_html 'participation_tab', :partial => 'base_page/participation/participation'
      end
    end
  end

  # create or update a user_participation object, granting new access.
  # this is currently unused
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

  def update
    upart = (UserParticipation.find(params[:upart_id]) if params[:upart_id])
    gpart = (GroupParticipation.find(params[:gpart_id]) if params[:gpart_id])
    part = upart || gpart
    entity = part.entity
    if params[:access] == 'remove'
      destroy
    else
      @page.add(entity, :access => params[:access]).save!
      render :update do |page|
        page.replace_html dom_id(part), :partial => 'base_page/participation/permission_row', :locals => {:participation => part.reload}
      end
    end
  end

  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access.
  def destroy
    error = I18n.t(:remove_access_error)
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

  def update_share_all
    if params[:add]
      @page.add(Site.current.network, :access=>Conf.default_page_access).save!
    else
      @page.remove(Site.current.network)
    end
    @page.updated_by = current_user
    @page.save
    render :template => 'base_page/reset_sidebar'
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
    group = current_site.tracking? && @group
    user  = current_site.tracking? && current_user
    Tracking.insert_delayed(
      :page => @page, :action => action,
      :group => group, :current_user => user
    )
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

  def set_owner
    owner = Entity.find_by_name!(params[:owner_name])
    if owner and owner != current_user and !current_user.member_of?(owner)
      raise_denied
    end
    @page.owner = owner
    if @page.owner_name_changed?
      current_user.updated(@page)
      @page.save!
    end
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

end
