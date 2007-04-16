
class Tool::TasklistController < Tool::BaseController
  before_filter :fetch_task_list
  stylesheet 'tasks'
  
  def show 
  end
   
  # ajax only, returns nothing
  def sort
    ids = params['pending_tasks'] || params['completed_tasks']
    @list.tasks.each do |task|
      i = ids.index( task.id.to_s )
      task.update_attribute('position',i+1) if i
    end
    render :nothing => true
  end
  
  # ajax only, returns rjs
  def create_task
    return unless request.xhr?
    @task = Task::Task.new(params[:task])
    @task.task_list = @list
    @task.save
  end
  
  # ajax only, returns rjs
  def mark_task_complete
    return unless request.xhr?
    @task = @list.tasks.find(params[:id])
    @task.completed = true
    @task.move_to_bottom # also saves task
  end

  # ajax only, returns rjs
  def mark_task_pending
    return unless request.xhr?
    @task = @list.tasks.find(params[:id])
    @task.completed = false
    @task.move_to_bottom # also saves task
  end
  
  # ajax only, returns nothing
  def destroy_task
    return unless request.xhr?
    @task = @list.tasks.find(params[:id])
    @task.remove_from_list
    @task.destroy
    render :nothing => true
  end
  
  # ajax only, returns rjs
  def update_task
    return unless request.xhr?
    @task = @list.tasks.find(params[:id])
    @task.update_attributes(params[:task])
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
