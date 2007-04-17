require 'task/task_list'

class Tool::TaskList < Page

  controller 'tasklist'
  model Task::TaskList
  icon 'task.png'
  tool_type 'task list'
  
end
