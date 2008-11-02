PageClassRegistrar.add(
  'ExternalVideoPage',
  :controller => 'external_video_page',
  :model => 'ExternalVideo',
  :icon => 'page_video',
  :class_display_name => 'video',
  :class_description => :video_class_description,
  :class_group => 'video', 
  :order => 21
)

#self.override_views = true
self.load_once = false

