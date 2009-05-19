# Include hook code here

PageClassRegistrar.add(
  'AssetPage',
  :controller => 'asset_page',
  :model => 'Asset',
  :icon => 'page_package',
  :class_group => ['media', 'media:image', 'media:audio', 'media:document'],
  :order => 20
)

#self.override_views = true
self.load_once = false

