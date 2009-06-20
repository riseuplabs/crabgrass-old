# Include hook code here

PageClassRegistrar.add(
  'TaskListPage',
  :controller => 'task_list_page',
  :model => 'TaskList',
  :icon => 'page_tasks',
  :class_group => ['planning', 'task'],
  :order => 3
)

#self.override_views = true
self.load_once = false

