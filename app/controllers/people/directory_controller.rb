#
# A controller for the directory of users
#

class People::DirectoryController < People::BaseController

  layout 'directory'
  helper :people

  before_filter :login_required, :action => 'show'

  def index
    # the drectory link shows my friends if there are friends, otherwise browse directory
    friends_list
    if @users.empty?
      redirect_to(:action=>'show', :id=>:browse)
    else
      redirect_to(:action=>'show', :id=>:friends)
    end
  end

  def show
    if id?(:friends, :peers, :browse, :recent)
      self.send(params[:id])
    else
      render_permission_denied
    end
  end

  protected

  def friends
    @users || friends_list
    # what letters can be used for pagination
    @pagination_letters = (User.friends_of(current_user).on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    @second_nav = 'my'
  end

  def friends_list
    @users = (User.friends_of(current_user).on(current_site).alphabetized(@letter_page)).paginate(pagination_params)
  end

  def peers
    @users = User.peers_of(current_user).on(current_site).alphabetized(@letter_page).paginate(pagination_params)
     # what letters can be used for pagination
    @pagination_letters = (User.peers_of(current_user).on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    @description_key = :directory_peers_description
    @second_nav = 'peers'
  end

  def browse
    @users = User.on(current_site).alphabetized(@letter_page).paginate(pagination_params)
    # what letters can be used for pagination
    @pagination_letters = (User.on(current_site).logins_only).collect{|u| u.login.first.upcase}.uniq
    @second_nav = 'all'
    @third_nav = 'browse'
  end

  def recent
    @users = User.on(current_site).recent.paginate(pagination_params)
    @second_nav = 'all'
    @third_nav = 'discover'
    render :action => 'recent'
  end

  protected

  def authorized?
    true
  end

  before_filter :prepare_pagination
  def prepare_pagination
    @letter_page = params[:letter] || ''
  end

  def context
    person_context
  end

end

