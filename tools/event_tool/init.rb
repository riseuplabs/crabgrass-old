
=begin
PageClassRegistrar.add(
  'EventPage',
  :controller => 'event_page',
  :model => 'Event',
  :icon => 'date.png',
  :class_display_name => 'event',
  :class_description => 'An event added to the personal/group/public calendar.',
  :class_group => 'event'
)
=end

#self.override_views = true
self.load_once = false

