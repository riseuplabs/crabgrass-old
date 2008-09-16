PageClassRegistrar.add(
  'Collection',
  :controller => 'collection',
  :icon => 'collection.png',
  :class_display_name => 'collection',
  :class_description => 'Special pages that hold other pages.',
  :class_group => 'collection',
  :order => 21
)

self.override_views = true
self.load_once = false
