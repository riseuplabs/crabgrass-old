#
# This controller is in charge of rendering the root url.
#
class RootController < ApplicationController
  helper :group, :account

  def index
    if !logged_in?
      login_page
    elsif current_site.network
      site_home
    else
      redirect_to me_url
    end
  end

  protected

  def site_home
    @group = current_site.network
    @active_tab = :networks # only tmp needed
#    @banner = render_to_string(:partial => 'banner')
    @left_column = render_to_string(:partial => 'group/sidebar')
    @groups = Group.visible_on(current_site).visible_by(current_user).only_groups.recent.find(:all, :limit => 10)
    @users = current_site.users.find(:all, :order => 'memberships.total_visits', :limit => 10)
    @recent_pages = Page.find_by_path(['descending', 'updated_at', 'limit','20'], options_for_group(@group))
    @most_viewed_pages = Page.find_by_path(['descending', 'views_count', 'limit','10'], options_for_group(@group))

    render :template => 'root/site_home'    
  end

  def login_page
    @stylesheet = 'account'
    render :template => 'account/index'
  end

end

