# Membership Controller
# All the relationships between users and groups are managed by this controller,

class Groups::MembershipsController < Groups::BaseController
  permissions 'groups/memberships', 'groups/requests'

  before_filter :fetch_membership, :only => :destroy
  before_filter :fetch_group, :login_required
  skip_before_filter :fetch_group, :only => :destroy

  verify :method => :post, :only => [:join]
  verify :method => :delete, :only => [:destroy]
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
    flash_message :success => I18n.t(:membership_leave_message, :group => @group.name)
    redirect_to url_for_group(@group)
  end

  def destroy
    @group = @membership.group
    @user = @membership.user
    @group.remove_user!(@user)

    redirect_to :action => 'list', :id => @group
  end

  # used when you have admin access to a group that you
  # or when this is an open group
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
    add_context I18n.t(:membership), url_for(:controller=>'groups/memberships', :action => 'list', :id => @group)
    #@left_column = render_to_string :partial => 'sidebar'
    @title_box = render_to_string :partial => 'title_box'
  end

  before_filter :prepare_pagination
  def prepare_pagination
    @page_number = params[:page] || 1
    @per_page = current_site.pagination_size
    @letter_page = params[:letter] || ''
  end

  def fetch_membership
    @membership = Membership.find(params[:id])
  end

end
