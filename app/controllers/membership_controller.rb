# Membership Controller
# All the relationships between users and groups are managed by this controller,

class MembershipController < ApplicationController

  stylesheet 'groups'
  helper 'groups', 'application'
    
  before_filter :login_required

  ###### PUBLIC ACTIONS #########################################################
  
  def list
    
  end
  
  ###### MEMBER ACTIONS #########################################################
  
  # leave this group
  def leave
    return unless request.post? # show form on get
    
    current_user.groups.delete(@group)
    flash_message :success => 'You have been removed from %s' / @group.name
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
        @group.memberships.create(:user => u) if u.member_of?(@group.parent) and not u.direct_member_of?(@group)
      end
      flash_message :success => 'member list updated'
    end
    redirect_to :action => 'list', :id => @group
  end
    
  protected
    
  def context
    group_context
    add_context 'membership', url_for(:controller=>'membership', :action => 'list', :id => @group)
  end
  
  prepend_before_filter :fetch_group
  def fetch_group
    @group = Group.get_by_name params[:id].sub(' ','+') if params[:id]
  end
  
  before_filter :setup_sidebar
  def setup_sidebar
    @left_column = render_to_string :partial => 'sidebar'
    @title_box = render_to_string :partial => 'title_box'
  end
  
  def authorized?
    return false unless logged_in?
    return true if current_user.member_of? @group
    if action?(:list)
      return @group.profiles.visible_by(current_user).may_see_members?
    elsif action?(:join)
      return @group.profiles.visible_by(current_user).may_request_membership?
    else
      return false
    end
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
