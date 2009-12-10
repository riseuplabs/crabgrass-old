

PageClassRegistrar.add(
  'EventPage',
  :controller => 'event_page',
  :model => 'Event',
  :icon => 'date',
  :class_group => 'planning',
  :internal => true
)

#self.override_views = true
self.load_once = false

