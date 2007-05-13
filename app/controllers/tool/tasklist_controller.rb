
class Tool::TasklistController < Tool::BaseController
  before_filter :fetch_task_list
  after_filter :update_participations,
    :only => [:create_task, :mark_task_complete, :mark_task_pending, :destroy_task, :update_task]
  stylesheet 'tasks'
  
  def show 
  end
   
  # ajax only, returns nothing
  # for this to work, there must be a <ul id='sort_list_xxx'> element
  # and it must be declared sortable like this:
  # <%= sortable_element 'sort_list_xxx', .... %>
  def sort
    sort_list_key = params.keys.grep(/^sort_list_/)
    if sort_list_key.any?
      ids = params[sort_list_key[0]]
      @list.tasks.each do |task|
        i = ids.index( task.id.to_s )
        task.update_attribute('position',i+1) if i
      end
      if ids.length > @list.tasks.length
        new_ids = ids.reject {|t| @list.task_ids.include?(t.to_i) }
        new_ids.each {|id| Task::Task.update(id, :position => ids.index(id)+1, :task_list_id => @list.id) }
      end
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
  
  def update_participations
    users_pending = {}
    page_resolved = true

    # build a hash of the completed status for each user
    @list.tasks.each do |task|
      task.users.each do |user|
        users_pending[user] ||= (not task.completed?)
      end
      page_resolved &&= task.completed?
    end

    # make the page resolved iff all the tasks are completed
    @page.update_attribute(:resolved, page_resolved) if @page.resolved? != page_resolved

    # update each user's resolved status
    users_pending.each do |user,pending|
      user.resolved(@page, (not pending))
    end
    current_user.updated(@page)
    true
  end
  
  def fetch_task_list
    unless @page.data
      @page.data = Task::TaskList.create
      @page.save
    end
    @list = @page.data
  end
  
end
