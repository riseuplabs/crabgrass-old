=begin

PersonContoller
================================

A controller which handles a single user. For processing collections of users,
see PeopleController.

=end

class PersonController < ApplicationController

  helper 'task_list_page', 'wall'

  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
  end
  
  def show
    params[:path] ||= "descending/updated_at"
    @activities = Activity.for_user(@user, (current_user if logged_in?)).newest.unique.find(:all)
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
    @profile = @user.profiles.visible_by(current_user)
    @post = Post.new(params[:post])
    @post.discussion = @profile.ensure_wall
    @post.user = current_user
    @post.save!
    redirect_to(:controller => 'person', :action => 'show', :id => @profile.user.login)
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
