=begin

PersonContoller
================================

A controller which handles a single user. For processing collections of users,
see PeopleController.

=end

class PersonController < ApplicationController

  helper 'task_list_page'

  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
  end
  
  def show
    params[:path] ||= "descending/updated_at"
    search
  end

  def search
    options = options_for_user(@user, :page => params[:page])
    @pages = Page.find_by_path params[:path], options
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
