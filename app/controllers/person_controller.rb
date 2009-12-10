=begin

PersonContoller
================================

A controller which handles a single user. For processing collections of users,
see PeopleController.

=end

class PersonController < ApplicationController

  helper 'task_list_page', 'profile'
  stylesheet 'tasks', :action => :tasks
  stylesheet 'messages', :action => :show
  permissions 'contact', 'profile', 'messages'

  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
  end

  def show
    @activities = Activity.for_user(@user, (current_user if logged_in?)).only_visible_groups.newest.unique.find(:all, :limit => 20)

    params[:path] ||= ""
    params[:path] = params[:path].split('/')
    params[:path] += ['descending', 'updated_at'] if params[:path].empty?
    params[:path] += ['limit','30', 'contributed_by', @user.id]

    @columns = [:stars, :owner_with_icon, :icon, :title, :last_updated]
    options = options_for_user(@user, :page => params[:page])
    @pages = Page.find_by_path params[:path], options
    if logged_in? and @user.may_show_status_to?(current_user)
      @status = @user.current_status
    end
  end

  def search
    redirect_to :controller => 'people' unless @user
    if request.post?
      path = parse_filter_path(params[:search])
      redirect_to url_for_user(@user, :action => 'search', :path => path)
    else
      @path.default_sort('updated_at').merge!(:contributed => @user.id)
      @pages = Page.paginate_by_path(@path, options_for_user(@user, :page => params[:page]))
      @columns = [:icon, :title, :owner, :updated_by, :updated_at, :contributors]
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

  protected

  def context
    person_context
    #unless ['show'].include? params[:action]
    #  add_context params[:action], people_url(:action => params[:action], :id => @user)
    #end
  end

  prepend_before_filter :fetch_user
  def fetch_user
    @user ||= User.find_by_login params[:id] if params[:id]
    true
  end

=begin

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
      # if the user is viewing their own profile, let them choose which one.
      if current_user == @user
        params[:profile] ||= 'private'
        if params[:profile] == 'private'
          @profile = @user.profiles.private
        elsif params[:profile] == 'public'
          @profile = @user.profiles.public
        end
        return true
      else
        @profile = @user.profiles.visible_by(current_user)
      end
    else
      @profile = @user.profiles.public
    end
    unless @profile and @profile.may_see?
      # make it appear as if the user does not exist if may_see? is false.
      # or should we show an empty profile page?
      @user = nil
      no_context
      render(:template => 'dispatch/not_found')
      false
    else
      params[:profile] ||= @profile.public? ? 'public' : 'private'
      true
    end
  end
  def load_partials
    @left_column = render_to_string :partial => 'person/sidebar', :locals => {:profile => @profile}
    true
  end

end
