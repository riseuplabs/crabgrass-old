# Include hook code here

PageClassRegistrar.add(
  'AssetPage',
  :controller => 'asset_page',
  :model => 'Asset',
  :icon => 'page_package',
  :class_display_name => 'file',
  :class_description => :file_class_description,
  :class_group => 'asset', 
  :order => 20
)

#self.override_views = true
self.load_once = false

