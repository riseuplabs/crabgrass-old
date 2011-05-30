class Groups::DirectoryController < Groups::BaseController

  helper 'autocomplete', 'map'
  layout 'directory'
  prepend_before_filter :set_group_type
  before_filter :fetch_groups, :only => [:recent, :search, :most_active]

  def index
    if logged_in?
      current_user.primary_groups.empty? ?
        redirect_to(:action => 'search') :
        redirect_to(:action => 'my')
    else 
      redirect_to(:action => 'search')
    end
  end

  def recent
    @groups = @all_groups.by_created_at.paginate(pagination_params)
    @second_nav = 'all'
    @misc_header = '/groups/directory/discover_header'
    @request_path = '/groups/directory/recent'
    render_list
  end

  def search
    letter_page = params[:letter] || ''
    @groups = @all_groups.alphabetized(letter_page).paginate(pagination_params)
    
    # get the starting letters of all groups
    all_group_names = @all_groups.names_only
    @pagination_letters = Group.pagination_letters_for(all_group_names)
    @second_nav = 'all'
    @misc_header = '/groups/directory/browse_header'
    request_root = (@group_type == :group) ? '/groups' : '/networks'
    @request_path = request_root+'/directory/search'
    render_list
  end

  def my
    @groups ||= my_groups 
    @show_committees = true
    @second_nav = 'my'
    render_list
  end

  def most_active
    user = logged_in? ? current_user : nil
    @groups = @all_groups.most_visits.paginate(pagination_params)
    render_list
  end



  protected

  def my_groups
    current_user.primary_groups.alphabetized('').paginate(pagination_params)
  end

  def fetch_groups
    @location_params = params.slice(:country_id, :state_id, :city_id)
    @all_groups = Group.only_type(@group_type).without_site_network
    @all_groups = @all_groups.visible_by(current_user)
    @all_groups = @all_groups.located_in(@location_params)
  end

  def render_list
    unless request.xhr?
      render :template => 'groups/directory/list'
    else
      render :update do |page|
        page.replace_html 'group_directory_list',
          :partial => '/groups/directory/group_directory_list'
      end
    end
  end

  def context
    group_context
  end

  def set_group_type
    @group_type = :group
  end

end
