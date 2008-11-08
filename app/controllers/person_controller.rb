=begin

PersonContoller
================================

A controller which handles a single user. For processing collections of users,
see PeopleController.

=end

class PersonController < ApplicationController

  helper 'task_list_page', 'wall', 'profile'

  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
  end
  
  before_filter :load_partials
  def load_partials
    @left_column = render_to_string :partial => 'person/sidebar', :locals => {:profile => @user.profiles.visible_by(current_user)}
  end
  
  def show
    @pages = Page.find_by_path('descending/updated_at/ascending/group_name/limit/40', options_for_me)
    params[:path] ||= "descending/updated_at"
    @activities = Activity.for_user(@user, (current_user if logged_in?)).newest.unique.find(:all)
    
       @wall_discussion = @user.ensure_discussion
    if params[:show_full_wall]
      @wall_posts = @wall_discussion.posts.all(:order => 'created_at DESC')
    else
      @wall_posts = @wall_discussion.posts.all(:order => 'created_at DESC')[0..9]
    end
    
    search
   
  end

  def search
    options = options_for_user(@user, :page => params[:page])
    @pages = Page.paginate_by_path params[:path], options
    @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors]
  end

  def tasks
    @stylesheet = 'tasks'
    options = options_for_user(@user)
    #options[:conditions] += " AND user_participations.resolved = ?"
    #options[:values] << false
    @pages = Page.find_by_path('type/task/pending', options)
    @task_lists = @pages.collect{|p|p.data}
  end
  
   def add_wall_message
    # 1. get the user, whos discussionis edited
    # 2. get the userr, who is editing the discussion
    # if it's  private, we get UserRelation.blabla
    # if not, we take @user.discussion
   # @profile = @user.profiles.visible_by(current_user)
    # @user = User.find(params[:id])
    if @user.discussion.nil?
      @user.discussion = Discussion.create
    end
    @discussion = @user.discussion
    # TODO how do we find out if user is allowed to post  in here?
    @post = Post.new(params[:post])
    @post.discussion  = @user.discussion
    # don't see the reason for ensure_wall
    # @post.discussion = @user.ensure_wall
    @post.user = current_user
    @post.save!
    @user.discussion.save
    
    redirect_to(url_for_user(@user))
  end
   
  protected
  
  def context
    person_context
    unless ['show'].include? params[:action]
      add_context params[:action], people_url(:action => params[:action], :id => @user)
    end
  end
  
  prepend_before_filter :fetch_user
  def fetch_user 
    @user ||= User.find_by_login params[:id] if params[:id]
    @is_contact = (logged_in? and current_user.contacts.include?(@user))
    true
  end
  
end
