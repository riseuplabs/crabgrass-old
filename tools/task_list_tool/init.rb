# Include hook code here

PageClassRegistrar.add(
  'TaskListPage',
  :controller => 'task_list_page',
  :model => 'TaskList',
  :icon => 'task-list.png',
  :class_display_name => 'task list',
  :class_description => :task_list_class_description,
  :class_group => 'task',
  :order => 3
)

#self.override_views = true
self.load_once = false

