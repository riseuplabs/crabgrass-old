
PageClassRegistrar.add(
  'WikiPage',
  :controller => 'wiki_page',
  :model => 'Wiki',
  :icon => 'wiki.png',
  :class_display_name => 'wiki',
  :class_description => 'A free-form text document.',
  :class_group => 'wiki'
)

#self.override_views = true
self.load_once = false

