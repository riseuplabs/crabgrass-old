# Membership Controller
# All the relationships between users and groups are managed by this controller,

class MembershipController < ApplicationController

  stylesheet 'groups'
  helper 'group', 'application'
  permissions 'membership', 'group'
    
  before_filter :login_required

  ###### PUBLIC ACTIONS #########################################################

  # list all members of the group
  def list
    # disabled for the sites mode - do we want membership by site?
    # @memberships =  @group.memberships.select{|ship| current_site.network.users.include?(ship.user)}.alphabetized_by_user(@letter_page).paginate(:page => @page_number, :per_page => @per_page)
   @memberships = @group.memberships.alphabetized_by_user(@letter_page).paginate(:page => @page_number, :per_page => @per_page)
   @pagination_letters = @group.memberships.with_users.collect{|m| m.user.login.first.upcase}.uniq
  end

  # list groups belonging to a network
  def groups
    @federatings = @group.federatings.alphabetized_by_group
  end

  # edit committee settings (add/remove users) or admin a group (currently n/a)
  def edit
  end
  
  ###### MEMBER ACTIONS #########################################################
  
  # leave this group
  def leave
    return unless request.post? # show form on get
    
    @group.remove_user!(current_user)
    flash_message :success => 'You have been removed from %s' / @group.name
    redirect_to url_for_group(@group)
  end
  
  # used only in the special case when you have admin access to a group that you are not yet directly a member of
  def join
    @group.add_user!(current_user)
    redirect_to url_for_group(@group)
  end
  
  ###### ADMIN ACTIONS #########################################################

  def update
    return redirect_to(:action => 'list', :id => @group) unless request.post?

    if @group.committee? and params[:group]
      new_ids = params[:group][:user_ids]
      @group.memberships.each do |m|  
        m.destroy if m.user.member_of?(@group.parent) and not new_ids.include?(m.user_id.to_s)
      end
      new_ids.each do |id|
        next unless id.any?
        u = User.find(id)
        @group.add_user!(u) if u.member_of?(@group.parent) and not u.direct_member_of?(@group)
      end
      flash_message :success => 'member list updated'
    end
    redirect_to :action => 'list', :id => @group
  end
    
  protected
    
  def context
    group_context
    add_context 'Membership', url_for(:controller=>'membership', :action => 'list', :id => @group)
  end
  
  prepend_before_filter :fetch_group
  def fetch_group
    @group = Group.find_by_name params[:id]
  end
  
  before_filter :setup_sidebar
  def setup_sidebar
    @left_column = render_to_string :partial => 'sidebar'
    @title_box = render_to_string :partial => 'title_box'
  end
  
  before_filter :prepare_pagination
  def prepare_pagination
    @page_number = params[:page] || 1
    @per_page = 20
    @letter_page = params[:letter] || ''
  end

  def authorized?
    return false unless logged_in?
    may_action?(params[:action], @group)
  end

  def access_denied
    respond_to do |accepts|
      accepts.html do
        if logged_in?
          render :action => 'show_nothing'
        else
          flash[:error] = 'Please login to perform that action.'
          redirect_to :controller => '/account', :action => 'login', :redirect => request.request_uri
        end
      end
      accepts.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render :text => "Could't authenticate you", :status => '401 Unauthorized'
      end
    end
    false
  end  

end
