class Groups::DirectoryController < Groups::BaseController

  helper 'locations'
  layout 'directory'
  before_filter :set_group_type

  def index
    if logged_in?
      my_groups
      @groups.empty? ? redirect_to(:action => 'search') : redirect_to(:action => 'my')
    else 
      redirect_to(:action => 'search')
    end
  end

  def recent
    user = logged_in? ? current_user : nil
    if params[:country_id]
      loc_options = {:country_id => params[:country_id], :state_id => params[:state_id], :city_id => params[:city_id]}
      @groups = Group.only_type(@group_type, @current_site).visible_by(user).in_location(loc_options).by_created_at.paginate(pagination_params)
      render :update do |page|
        page.replace_html 'group_directory_list', :partial => '/groups/directory/group_directory_list'
      end
    else
      @groups = Group.only_type(@group_type, @current_site).visible_by(user).by_created_at.paginate(pagination_params)
      @second_nav = 'all'
      @misc_header = '/groups/directory/discover_header'
      @request_path = '/groups/directory/recent'
      render_list
    end
  end

  def search
    user = logged_in? ? current_user : nil
    letter_page = params[:letter] || ''

    if params[:country_id] =~ /^\d+$/
      @params_location = {:country_id => params[:country_id], :state_id => params[:state_id], :city_id => params[:city_id]}
      @groups = Group.only_type(@group_type, @current_site).visible_by(user).in_location(@params_location).alphabetized(letter_page).paginate(pagination_params)
      groups_with_names = Group.only_type(@group_type, @current_site).visible_by(user).in_location(@params_location).names_only
    else
      @groups = Group.only_type(@group_type, @current_site).visible_by(user).alphabetized(letter_page).paginate(pagination_params)
      @params_location = {}
      groups_with_names = Group.only_type(@group_type, @current_site).visible_by(user).names_only
    end

    # get the starting letters of all groups
    @pagination_letters = Group.pagination_letters_for(groups_with_names)
    if request.xhr? #params[:country_id]
      render :update do |page|
        page.replace_html 'group_directory_list', :partial => '/groups/directory/group_directory_list'
      end
    else
      @second_nav = 'all'
      @misc_header = '/groups/directory/browse_header'
      request_root = (@group_type == :group) ? '/groups' : '/networks'
      @request_path = request_root+'/directory/search'
      render_list
    end
  end

  def my
    @groups || my_groups 
    @show_committees = true
    @second_nav = 'my'
    render_list
  end

  def most_active
    user = logged_in? ? current_user : nil
    @groups = Group.only_type(@group_type, @current_site).visible_by(user).most_visits.paginate(pagination_params)
    render_list
  end



  protected

  def my_groups
    @groups = current_user.primary_groups.alphabetized('').paginate(pagination_params)
  end

  def render_list
    render :template => 'groups/directory/list'
  end

  def context
    group_context
  end

  def set_group_type
    @group_type = :group
  end

end
