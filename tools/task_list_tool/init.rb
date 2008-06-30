# Include hook code here

PageClassRegistrar.add(
  'TaskListPage',
  :controller => 'task_list_page',
  :model => 'TaskList',
  :icon => 'task-list.png',
  :class_display_name => 'task list',
  :class_description => 'A list of todo items.',
  :class_group => 'task'
)

#self.override_views = true
self.load_once = false

