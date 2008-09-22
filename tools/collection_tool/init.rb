PageClassRegistrar.add(
  'Collection',
  :controller => 'collection',
  :icon => 'collection.png',
  :class_display_name => 'collection',
  :class_description => 'Special pages that hold other pages.',
  :class_group => 'collection',
  :order => 30
)

PageClassRegistrar.add(
  'Folder',
  :controller => 'folder_page',
  :icon => 'collection.png',
  :class_display_name => 'folder',
  :class_description => 'A collection of assets',
  :class_group => ['collection','folder'],
  :order => 32
)

self.override_views = false
self.load_once = false

