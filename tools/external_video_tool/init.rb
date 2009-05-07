PageClassRegistrar.add(
  'ExternalVideoPage',
  :controller => 'external_video_page',
  :model => 'ExternalVideo',
  :icon => 'page_video',
  :class_group => 'media:video', 
  :order => 21
)

#self.override_views = true
self.load_once = false

