# Include hook code here

PageClassRegistrar.add(
  'AssetPage',
  :controller => 'asset_page',
  :model => 'Asset',
  :icon => 'package.png',
  :class_display_name => 'file',
  :class_description => 'an uploaded file',
  :class_group => 'asset', 
  :order => 20
)

#self.override_views = true
self.load_once = false

