# TaskListPage

class TaskListPage < Page

  # Return string of all tasks, for the full text search index
  def index_data
    data.tasks.collect { |task| "#{task.name}\t#{task.description}" }.join "\n"
  end

end

