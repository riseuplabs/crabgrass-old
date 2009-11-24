PageClassRegistrar.add(
  'Gallery',
  :controller => 'gallery',
  :icon => 'page_gallery',
  :class_group => ['media', 'media:image', 'collection'],
  :order => 30
)

apply_mixin_to_model("Asset", "AssetsHaveGalleries")

self.override_views = false
self.load_once = false

