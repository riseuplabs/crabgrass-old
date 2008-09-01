# TaskListPage

class TaskListPage < Page

  # Return string of all tasks, for the full text search index
  def body_terms
    return "" unless data and data.tasks
    data.tasks.collect { |task| "#{task.name}\t#{task.description}" }.join "\n"
  end

end

