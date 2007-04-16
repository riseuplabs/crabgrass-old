
class Tool::TasklistController < Tool::BaseController
  before_filter :fetch_task_list
      
  def show 
  end
   
  # reorder the tasks
  # ajax only, returns status string.
  def reorder
    return unless request.xhr?  
    success = 0
    i = 0
    tasks = @params[:tasks]
    tasks.each_with_index do |id,i|
      task = Task::Task.find(id)
      task.position = i
      success += 1 if task.save
    end

    if tasks.length == success
      render :text => "Updated Sort Order"
    else
      render :text => "Some Items Weren't Saved"
    end
  end

  def sort
    for id in params['pending_tasks']
      task = @list.tasks.detect{|t| t.id == id.to_i}
      task.move_to_bottom if task
    end
#    @list.tasks.each do |task|
      #task.position = params['pending_tasks'].index(task.id.to_s) + 1
      #task.save
#    end
    render :nothing => true
  end
  
  # create_task
  # ajax only, returns partial HTML
  def create_task
    return unless @request.xhr?
    @task = Task::Task.new( @params['task']['new'] )
    @task.task_list = @list
    @task.save
    #render :partial=>'task', :locals=>{:task=>task}
  end
  
  # ajax only, returns rjs
  def mark_task_complete
    return unless request.xhr?
    @task = @list.tasks.find(params[:id])
    @task.completed = true
    @task.move_to_bottom
    #@task.save
  end

  # ajax only, returns rjs
  def mark_task_pending
    return unless request.xhr?
    @task = @list.tasks.find(params[:id])
    @task.completed = false
    @task.move_to_bottom
    #@task.save
  end
    
  protected 
  
  def fetch_task_list
    unless @page.data
      @page.data = Task::TaskList.create
      @page.save
    end
    @list = @page.data
  end
  
end
