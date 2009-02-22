class GroupsController < ApplicationController

  stylesheet 'groups'
  helper 'group'
   
  before_filter :login_required, :only => [:create]

  def index
    user = logged_in? ? current_user : nil
    @groups = Group.visible_by(user).only_groups.recent.paginate(:all, :page => params[:page])
  end

  def directory
    user = logged_in? ? current_user : nil
    letter_page = params[:letter] || ''

    @groups = Group.visible_by(user).only_groups.alphabetized(letter_page).paginate(:all, :page => params[:page])

    # get the starting letters of all groups
    groups_with_names = Group.visible_by(user).only_groups.names_only
    @pagination_letters = groups_available_pagination_letters(groups_with_names)
  end

  def my
    @groups = current_user.groups.alphabetized('')
    @groups.each {|g| g.display_name = g.parent.display_name + "+" + g.display_name if g.committee?}
  end

  # login required
  def create
    @group_class = get_group_class
    @group_type = @group_class.to_s.downcase
    @parent = get_parent
    if request.get?
      @group = @group_class.new(params[:group])
    elsif request.post?
      @group = @group_class.create!(params[:group]) do |group|
        group.avatar = Avatar.new
        group.created_by = current_user
      end
      flash_message :success => 'Group was successfully created.'[:group_successfully_created]
      @group.add_user!(current_user)
      @parent.add_committee!(@group, params[:group][:is_council] == "true" ) if @parent

      add_council if params[:add_council] == "true"
      
      redirect_to url_for_group(@group)
    end
  rescue Exception => exc
    @group = exc.record if exc.record.is_a? Group
    flash_message :exception => exc
  end
       
  protected
  
  before_filter :setup_view
  def setup_view
     group_context
     set_banner "groups/banner", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  def authorized?
    true
  end
  
  def get_group_class
    type = params[:id].any? ? params[:id] : 'group'
    type = 'committee' if params[:parent_id]
    unless ['committee','group','network'].include? type
      raise ErrorMessage.new('Could not understand group type :type'[:dont_understand_group_type] %{:type => type})
    end
    Kernel.const_get(type.capitalize)
  end

  def get_parent
    parent = Group.find(params[:parent_id]) if params[:parent_id]
    if parent and not current_user.may?(:admin, parent)
      raise ErrorMessage.new('You do not have permission to create committees under %s'[:dont_have_permission_to_create_committees] % parent.name)
    end
    parent
  end

  def add_council
    debugger
    council_params = {
      :short_name => @group.short_name + '_admin',
      :full_name => @group.full_name + ' Admin',
      :publicly_visible_group => @group.publicly_visible_group,
      :publicly_visible_members => @group.publicly_visible_members,
      :is_council => "true",
      :accept_new_membership_requests => "0",
    }
      
    @council = Committee.create!(council_params) do |c|
      c.avatar = Avatar.new
      c.created_by = current_user
    end
      
    @council.add_user!(current_user)
    
    @group.add_committee!(@council, true)
  end

  def groups_available_pagination_letters(groups)
    pagination_letters = []
    groups.each do |g|
      pagination_letters << g.full_name.first.upcase if g.full_name
      pagination_letters << g.name.first.upcase if g.name
    end

    return pagination_letters.uniq!
  end

end

