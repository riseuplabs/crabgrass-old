
PageClassRegistrar.add(
  'RateManyPage',
  :controller => 'rate_many_page',
  :model => 'Poll',
  :icon => 'rate-many.png',
  :class_display_name => 'approval vote',
  :class_description => :approval_vote_class_description,
  :class_group => 'poll',
  :order => 10
)

#self.override_views = true
self.load_once = false

