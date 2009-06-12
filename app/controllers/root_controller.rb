#
# This controller is in charge of rendering the root url.
#
class RootController < ApplicationController
  helper :group, :account

  stylesheet 'wiki_edit'
  javascript 'wiki_edit'

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
    @active_tab = :home

    @recent_pages = Page.find_by_path(['descending', 'updated_at', 'limit','20'], options_for_group(@group))
    @most_viewed_pages = Page.find_by_path(['descending', 'views_count', 'limit','10'], options_for_group(@group))
    @group.profiles.public.create_wiki unless @group.profiles.public.wiki

    render :template => 'root/site_home'    
  end

  def login_page
    @stylesheet = 'account'
    @active_tab = :home
    render :template => 'account/index'
  end

  helper_method :most_active_groups
  def most_active_groups
    Group.only_groups.most_visits.find(:all, :limit => 5)
  end
  
  helper_method :recently_active_groups
  def recently_active_groups
    Group.only_groups.recent_visits.find(:all, :limit => 10)
  end

  helper_method :most_active_users
  def most_active_users
    User.most_active_on(current_site, nil).not_inactive.find(:all, :limit => 5)
  end

  helper_method :recently_active_users
  def recently_active_users
    User.most_active_on(current_site, Time.now - 30.days).not_inactive.find(:all, :limit => 10)
  end

#    @groups = Group.visible_by(current_user).only_groups.recent.find(:all, :limit => 10)
#    @users = User.most_active_on(current_site, Time.now - 30.days).not_inactive.find(:all, :limit => 10)


end

