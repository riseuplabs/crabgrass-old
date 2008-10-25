PageClassRegistrar.add(
  'Collection',
  :controller => 'collection',
  :icon => 'collection.png',
  :class_display_name => 'collection',
  :class_description => :collection_class_description,
  :class_group => 'collection',
  :order => 30
)

PageClassRegistrar.add(
  'Folder',
  :controller => 'folder_page',
  :icon => 'collection.png',
  :class_display_name => 'folder',
  :class_description => :folder_class_description,
  :class_group => ['collection','folder'],
  :order => 32
)

self.override_views = false
self.load_once = false

