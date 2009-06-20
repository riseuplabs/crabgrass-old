PageClassRegistrar.add(
  'ExternalVideoPage',
  :controller => 'external_video_page',
  :model => 'ExternalVideo',
  :icon => 'page_video',
  :class_group => ['media', 'media:video'],
  :order => 20
)

#self.override_views = true
self.load_once = false

