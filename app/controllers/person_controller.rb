=begin

PersonContoller
================================

A controller which handles a single user. For processing collections of users,
see PeopleController.

=end

class PersonController < ApplicationController

  helper 'task_list_page', 'wall', 'profile'
  stylesheet 'tasks', :action => :tasks

  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
  end
    
  def show
    @activities = Activity.for_user(@user, (current_user if logged_in?)).newest.unique.find(:all)
    
    @wall_discussion = @user.ensure_discussion
    if params[:show_full_wall]
      @wall_posts = @wall_discussion.posts.all(:order => 'created_at DESC')
    else
      @wall_posts = @wall_discussion.posts.all(:order => 'created_at DESC')[0..9]
    end
    
    params[:path] ||= ""
    params[:path] = params[:path].split('/')
    params[:path] += ['descending', 'updated_at'] if params[:path].empty?
    params[:path] += ['limit','30', 'contributed', @user.id]

    @columns = [:stars, :owner_with_icon, :icon, :title, :last_updated]
    options = options_for_user(@user, :page => params[:page])
    @pages = Page.find_by_path params[:path], options
  end

  def search
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to url_for_user(@user, :action => 'search', :path => path)
    else
      params[:path] = ['descending', 'updated_at'] if params[:path].empty?
      params[:path] += ['contributed', @user.id]
      @pages = Page.paginate_by_path(params[:path], options_for_user(@user, :page => params[:page]))
      @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors]
    end
    handle_rss :title => @user.name, :link => url_for_user(@user),
      :image => avatar_url_for(@user, 'xlarge')
  end

  def tasks
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

=begin

  I don't understand what this is trying to accomplish, but I don't
  think this is the right way to do it, whatever it is. -elijah

  def fetch_profile
    if logged_in?
        if current_user.id == @user.id
          'friends' # not so sure about this
        elsif current_user.friend_of? @user.id
          'friends'
        elsif current_user.peer_of? @user
          'peers'
        else
          'users'
        end
      else
        'everyone'
      end
    if(@site.profiles.private? && 
       @site.profiles.private.visible_to?(vis_group))
      @profile = @user.profiles.private
    elsif(@site.profiles.public? &&
          @site.profiles.public.visible_to?(vis_group))
      @profile = @user.profiles.public
    end
    unless @profile
      raise PermissionDenied
    end
  end
=end
  
  before_filter :fetch_profile, :load_partials
  def fetch_profile
    if logged_in?
      @profile = @user.profiles.visible_to(current_user)
    else
      @profile = @user.profiles.public
    end
    unless @profile and @profile.may_see?
      @user = nil
      no_context
      render(:template => 'dispatch/not_found')
      false
    else
      true
    end
  end
  def load_partials
    @left_column = render_to_string :partial => 'person/sidebar', :locals => {:profile => @profile}
    true
  end

end
