require 'task/task_list'

class Tool::TaskList < Page

  controller 'tasklist'
  model ::TaskList
  icon 'task-list.png'
  class_display_name 'task list'
  class_description 'A list of todo items.'
  class_group 'task'
    
end
