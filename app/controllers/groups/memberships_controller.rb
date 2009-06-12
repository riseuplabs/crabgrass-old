# Membership Controller
# All the relationships between users and groups are managed by this controller,

class Groups::MembershipsController < Groups::BaseController

  permissions 'memberships', 'requests' 
  before_filter :fetch_group, :login_required

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
        if m.user.member_of?(@group.parent) and !new_ids.include?(m.user_id.to_s)
          @group.remove_user!(m.user) 
        end
      end
      new_ids.each do |user_id|
        next unless user_id.any?
        user = User.find(user_id)
        @group.add_user!(user) if user.member_of?(@group.parent) and not user.direct_member_of?(@group)
      end
      flash_message :success => 'member list updated'
    end
    redirect_to :action => 'edit', :id => @group
  end
    
  protected
    
  def context
    @group_navigation = :membership
    super
    add_context 'Membership'[:membership], url_for(:controller=>'groups/memberships', :action => 'list', :id => @group)
    #@left_column = render_to_string :partial => 'sidebar'
    @title_box = render_to_string :partial => 'title_box'
  end
    
  before_filter :prepare_pagination
  def prepare_pagination
    @page_number = params[:page] || 1
    @per_page = current_site.pagination_size
    @letter_page = params[:letter] || ''
  end

  # what the hell is this doing here?
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
