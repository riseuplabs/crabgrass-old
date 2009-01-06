class Me::TasksController < Me::BaseController

  stylesheet 'me', 'tasks'
  javascript :extra
  helper 'task_list_page'

  # TODO
  # The way this works is incredibly stupid. Basically, we fetch all the task lists
  # that the user has access to and then we examine each task in those lists to see if
  # it has been completed. The problem is that we need to decide if we are searching for
  # *task lists* or *tasks*. If tasks, then we need some way to figure out what groups have
  # access to a particular task, or maybe that doesn't make sense since groups can't be
  # assigned to as task

  def pending
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to url_for(:controller => 'me/tasks',
        :action => params[:action], :path => nil) + path
    else
      list_tasks('pending')  
    end
  end
  def completed
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to url_for(:controller => 'me/tasks',
        :action => params[:action], :path => nil) + path
    else
      list_tasks('completed')
    end
  end

  def list_tasks(status)
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to url_for(:controller => 'me/tasks', :action => params[:action], :path => nil)
    else
      path = parsed_path.set_keyword('type','task').to_path
      @pages = Page.find_by_path(path, options_for_me)
      @task_lists = @pages.collect{|page|page.data}
      @show_user = current_user
      @show_status = status
      render :action => 'list'      
    end
  end

    
  protected
  
  def context
    me_context('large')
    add_context 'Tasks'[:me_tasks_link], url_for(:controller => '/me/tasks', :action => params[:action], :path => params[:path])
  end
  
end

