
PageClassRegistrar.add(
  'WikiPage',
  :controller => 'wiki_page',
  :icon => 'wiki.png',
  :class_display_name => 'wiki',
  :class_description => :wiki_class_description,
  :class_group => 'wiki',
  :order => 4
)

#self.override_views = true
self.load_once = false

