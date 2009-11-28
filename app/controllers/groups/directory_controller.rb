class Groups::DirectoryController < Groups::BaseController

  helper 'locations'

  before_filter :set_group_type

  def index
    logged_in? ? redirect_to(:action => 'my') : redirect_to(:action => 'search')
  end

  def recent
    user = logged_in? ? current_user : nil
    @groups = Group.only_type(@group_type).visible_by(user).paginate(:all, :order => 'groups.created_at DESC', :page => params[:page])
    render_list
  end

  def search
    user = logged_in? ? current_user : nil
    letter_page = params[:letter] || ''

    if params[:country_id]
      loc = params[:country_id]
      @groups = Group.only_type(@group_type).visible_by(user).in_location(loc).alphabetized(letter_page).paginate(:all, :page => params[:page])
      groups_with_names = Group.only_type(@group_type).visible_by(user).in_location(loc).names_only
    else
      @groups = Group.only_type(@group_type).visible_by(user).alphabetized(letter_page).paginate(:all, :page => params[:page])
      groups_with_names = Group.only_type(@group_type).visible_by(user).names_only
    end

    # get the starting letters of all groups
    @pagination_letters = Group.pagination_letters_for(groups_with_names)
    @include_location_filter = true;
    render_list
  end

  def my
    @groups = current_user.primary_groups.alphabetized('').paginate(:all, :page => params[:page])
    @show_committees = true
    render_list
  end

  def most_active
    user = logged_in? ? current_user : nil
    @groups = Group.only_type(@group_type).visible_by(user).most_visits.paginate(:all, :page => params[:page])
    render_list
  end



  protected

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
