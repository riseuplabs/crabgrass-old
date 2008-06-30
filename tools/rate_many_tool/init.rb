
PageClassRegistrar.add(
  'RateManyPage',
  :controller => 'rate_many_page',
  :model => 'Poll',
  :icon => 'rate-many.png',
  :class_display_name => 'approval vote',
  :class_description => 'Approve or disapprove of each possibility.',
  :class_group => 'poll'
)

#self.override_views = true
self.load_once = false

