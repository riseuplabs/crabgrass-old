class MyTasksController < ApplicationController

  before_filter :login_required
  before_filter :fetch_user
  stylesheet 'me', 'tasks'
  javascript :extra
  layout 'me'
  
  def index
    pending
  end
     
  def pending
    #@tasks = current_user.tasks.pending
    @pages = Page.find_by_path("type/task", options_for_me)
    @task_lists = @pages.collect{|page|page.data}
    @show_status = 'pending'
    @show_user = current_user
    
    render :action => 'index'
  end
  
  def completed
    #@tasks = current_user.tasks.completed
    @pages = Page.find_by_path("type/task", options_for_me)
    @task_lists = @pages.collect{|page|page.data}
    @show_status = 'completed'
    @show_user = current_user

    render :action => 'index'
  end
  
#  def urgent
#    @tasks = current_user.tasks.urgent
#    render :action => 'index'
#  end
  
  def group
    groupid = params[:id].to_i
    @pages = Page.find_by_path("type/task", options_for_group(groupid))
    @task_lists = @pages.collect{|page|page.data}
    @show_user = 'all'
    @show_status = 'both'
    render :action => 'index'
  end
     
  protected

  def authorized?
    return true
  end
  
  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('large')
    add_context 'tasks', url_for(:controller => 'my_tasks', :action => nil)
  end
  
end

