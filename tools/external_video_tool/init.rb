PageClassRegistrar.add(
  'ExternalVideoPage',
  :controller => 'external_video_page',
  :model => 'ExternalVideo',
  :icon => 'video.png',
  :class_display_name => 'video',
  :class_description => :video_class_description,
  :class_group => 'external_video', 
  :order => 21
)

#self.override_views = true
self.load_once = false

